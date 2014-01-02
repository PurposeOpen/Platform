# == Schema Information
#
# Table name: donations
#
#  id                     :integer          not null, primary key
#  user_id                :integer          not null
#  content_module_id      :integer          not null
#  amount_in_cents        :integer          not null
#  payment_method         :string(32)       not null
#  frequency              :string(32)       not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  active                 :boolean          default(TRUE)
#  last_donated_at        :datetime
#  page_id                :integer          not null
#  email_id               :integer
#  recurring_trigger_id   :string(255)
#  last_tried_at          :datetime
#  identifier             :string(255)
#  receipt_frequency      :string(255)
#  flagged_since          :datetime
#  flagged_because        :string(255)
#  dismissed_at           :datetime
#  currency               :string(255)
#  amount_in_dollar_cents :integer
#  order_id               :string(255)
#  transaction_id         :string(255)
#  subscription_id        :string(255)
#  subscription_amount    :integer
#

class Donation < ActiveRecord::Base
  include ActsAsUserResponse
  after_create :create_activity_event

  PAYMENT_METHODS = [:paypal, :credit_card]
  CREDIT_CARD_TYPES = [:visa, :mastercard, :american_express]

  # used to be used, currently not in use by the Purpose Platform
  # consider bringing back when implementing refunds and recurring donations.
  has_many :transactions

  before_validation :ensure_amount_is_also_stored_in_dollars
  before_validation :ensure_frequency_is_set

  validates_presence_of :payment_method
  validates_presence_of :currency
  validates_presence_of :frequency
  validates_uniqueness_of :transaction_id, :allow_nil => true
  validate :validate_content_module_is_a_donation_ask
  validate :validate_payment_method
  validate :validate_amounts
  validate :validate_transaction_id

  def self.total_in_dollar_cents_by_action_page(action_page_id)
    result = Donation.select('COALESCE(SUM(amount_in_dollar_cents), 0) as total').where(:page_id => action_page_id).group('donations.page_id')
    result.empty? ? 0 : result[0].total
  end

  def self.stats_by_action_page(action_page_id)
    result = Donation.select('COALESCE(COUNT(amount_in_dollar_cents), 0) as donations_count, COALESCE(SUM(amount_in_dollar_cents), 0) as total_money_collected').where(:page_id => action_page_id).group('donations.page_id')
    result.empty? ? [0,0] : [result[0].donations_count, result[0].total_money_collected]
  end

  def made_to
    action_page.action_sequence.campaign ? action_page.action_sequence.campaign.name : "Purpose"
  end

  def donation_amount
    if(self.frequency == 'one_off')
      Money.from_numeric(amount_in_cents.to_f / 100, currency).format
    else
      Money.from_numeric(subscription_amount.to_f / 100, currency).format
    end
  end

  def autofire_tokens
    {
      'DONATION_AMOUNT' => donation_amount,
      'DONATION_DATE' => self.created_at.to_date.to_s,
      'DONATION_TRANSACTION_ID' => "#{I18n.t('transaction_id', :locale => self.content_module.language.iso_code.to_sym)} #{self.transaction_id}",
      'DONATION_FREQUENCY' =>  I18n.t(self.frequency, :locale => self.content_module.language.iso_code.to_sym ),
      'DONATION_CANCELLATION' => self.is_recurrent ? I18n.t('donation_cancellation_message', :locale => self.content_module.language.iso_code.to_sym) : ' '
    }
  end

  def is_recurrent
    self.frequency != 'one_off'
  end

  def comment; nil; end

  # called for one_off donations
  def confirm
    self.active = true
    Donation.transaction do
      external_id, order_id = self.transaction_id, self.order_id
      transaction = create_transaction(external_id, order_id, self.amount_in_cents)
      transaction.save!
      self.save!
    end
  end

  def self.perform(donation_id)
    donation = Donation.find(donation_id)
    donation.make_payment_on_recurring_donation
  end

  def make_payment_on_recurring_donation
    return if self.frequency == :one_off || self.active == false
    transaction = purchase_on_spreedly

    if transaction.succeeded?
      transaction.respond_to?(:gateway_transaction_id) ? order_id = transaction.gateway_transaction_id : order_id = nil
      add_payment(transaction.amount, transaction.token, order_id)
      #TODO: email_confirming_payment
      enqueue_recurring_payment
    else
      handle_failed_recurring_payment
    end
  end

  def enqueue_recurring_payment
    if self.active? && frequency != :one_off
      case frequency
      when :weekly
        Resque.enqueue(1.week, self.class, self.id)
      when :monthly
        Resque.enqueue(1.month, self.class, self.id)
      when :annual
        Resque.enqueue(1.year, self.class, self.id)
      end
    end
  end

  def purchase_on_spreedly
    if self.classification == '501-c-3'
      spreedly = Spreedly::Environment.new(ENV['SPREEDLY_501C3_ENV_KEY'], ENV['SPREEDLY_501C3_APP_ACCESS_SECRET'])
    else
      spreedly = Spreedly::Environment.new(ENV['SPREEDLY_501C4_ENV_KEY'], ENV['SPREEDLY_501C4_APP_ACCESS_SECRET'])
    end

    gateway_token = determine_gateway_token
    spreedly.purchase_on_gateway(gateway_token, self.payment_method_token, self.subscription_amount)
  end

  def determine_gateway_token
    case self.currency.downcase
    when 'usd'
      # TODO: remove hard-coded test gateway token
      'DWqZNx7SyOHZyrscU7p5gzORxky'
    end
  end

  # called for recurring donations
  def add_payment(transaction_amount_in_cents, external_id, order_id)
    self.amount_in_cents += transaction_amount_in_cents
    self.active = true
    update_amount_in_dollar_cents
    Donation.transaction do
      transaction = create_transaction(external_id, order_id, transaction_amount_in_cents)
      transaction.save!
      self.save!
    end
  end

  private

  def create_transaction(external_id, invoice_id, amount_in_cents)
    transaction = Transaction.new(:donation => self,
        :external_id => external_id, # spreedly transaction_token
        :invoice_id => invoice_id,
        :amount_in_cents => amount_in_cents,
        :currency => self.currency,
        :successful => true)
    transaction
  end

  def ensure_frequency_is_set
    self.frequency ||= :one_off
  end

  def ensure_amount_is_also_stored_in_dollars
    return unless self.amount_in_dollar_cents.nil? || self.amount_in_dollar_cents == 0

    update_amount_in_dollar_cents
  end

  def update_amount_in_dollar_cents
    if self.currency.to_s.downcase == 'usd'
      self.amount_in_dollar_cents = self.amount_in_cents
    elsif !self.currency.nil? && !self.currency.empty? && !self.amount_in_cents.nil?
      amount_as_money = Money.new(self.amount_in_cents, self.currency)
      self.amount_in_dollar_cents = amount_as_money.exchange_to(:usd).cents
    end
  end

  def validate_content_module_is_a_donation_ask
    errors.add(:content_module, "is not a donation ask") unless content_module && content_module.is_a?(DonationModule)
  end

  def validate_payment_method
    errors.add(:payment_method, "is not a valid payment method") unless PAYMENT_METHODS.include?(self.payment_method.to_sym)
  end

  def validate_amounts
    [:amount_in_cents, :amount_in_dollar_cents].each do |amount_field|
      amount_value = self.send(amount_field)
      errors.add(amount_field, "is not valid") unless (self.active && amount_value.to_s =~ /\A[+-]?\d+\Z/ && amount_value.to_i > 0) || !self.active
    end
  end

  def validate_transaction_id
    errors.add(:transaction_id, "is not valid") unless (!self.transaction_id.nil? && !self.transaction_id.empty?) || self.frequency.to_sym != :one_off
  end

  def validate_subscription_id
    errors.add(:subscription_id, "is not valid") unless (!self.subscription_id.nil? && !self.subscription_id.empty?) || self.frequency.to_sym == :one_off
  end
end
