# encoding: utf-8
# == Schema Information
#
# Table name: content_modules
#
#  id                              :integer          not null, primary key
#  type                            :string(64)       not null
#  content                         :text
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  options                         :text
#  title                           :string(128)
#  public_activity_stream_template :string(255)
#  alternate_key                   :integer
#  language_id                     :integer
#  live_content_module_id          :integer
#

require 'money'

class DonationModule < ContentModule
  has_many :donations, :foreign_key => :content_module_id
  option_fields :default_currency, :suggested_amounts, :default_amount,
                :recurring_default_currency, :recurring_suggested_amounts, :recurring_default_amount,
                :button_text, :thermometer_threshold, :donations_goal,
                :frequency_options, :receipt_frequency, :commence_donation_at,
                :active, :disabled_title, :disabled_content

  after_initialize :defaults
  before_save :remove_whitespace_from_suggested_amounts,
              :remove_whitespace_from_recurring_suggested_amounts,
              :make_all_configured_frequencies_optional

  warnings do
    validates_length_of :title, :maximum => 128, :minimum => 3, :if => :needs_title?
    validates_length_of :public_activity_stream_template, :maximum => 1024, :minimum => 3, :if => :shows_activity_stream?
    validates_length_of :button_text, :minimum => 1, :maximum => 64
    validates_presence_of :donations_goal
    validates_numericality_of :donations_goal, :greater_than_or_equal_to => 0, :if => :donations_goal
    validates_numericality_of :thermometer_threshold, :greater_than_or_equal_to => 0, :less_than_or_equal_to => :donations_goal, :if => :donations_goal
    validate :default_currency_set_for_at_least_a_frequency
    validates_presence_of :receipt_frequency

    validate :suggested_and_default_amount_for_at_least_one_currency, :if => :one_off?
    validate :recurring_suggested_and_default_amount_for_at_least_one_currency, :if => :recurring?
    validate :all_suggested_amounts_are_greater_than_zero
    validate :default_amount_is_one_of_the_suggested_amounts
    validate :recurring_default_amount_is_one_of_the_recurring_suggested_amounts

    validate :one_frequency_option_must_be_the_default
    validates_presence_of :disabled_title, :unless => :active?
    validates_presence_of :disabled_content, :unless => :active?
  end

  def donations_goal=(value)
    write_option_field_value :donations_goal, value.to_i
  end

  def thermometer_threshold=(value)
    write_option_field_value :thermometer_threshold, value.to_i
  end

  AVAILABLE_CURRENCIES = {
    :aud => Money::Currency.new('AUD'),
    :cad => Money::Currency.new('CAD'),
    :eur => Money::Currency.new('EUR'),
    :gbp => Money::Currency.new('GBP'),
    :jpy => Money::Currency.new('JPY'),
    :usd => Money::Currency.new('USD')
  }

  FREQUENCIES = [:one_off, :weekly, :monthly, :annual]
  FREQUENCY_LABELS = {
    :one_off => "Donate Once",
    :weekly => "Donate Weekly",
    :monthly => "Donate Monthly",
    :annual => "Donate Annually"
  }

  placeable_in SIDEBAR

  def as_json(options={})
    super(options).tap do |json|
      json["options"]["suggested_amounts"].delete_if { |_, currency_amounts| currency_amounts.blank? }
      json["options"]["recurring_suggested_amounts"].delete_if { |_, currency_amounts| currency_amounts.blank? }
      json[:classification] = self.classification
      json[:donations_made] = count_donations_made
    end
  end

  def classification
    TaxDeductibleDonationModule::DONATION_CLASSIFICATION
  end

  def self.frequency_select_options
    FREQUENCY_LABELS.invert
  end

  def take_action(user, action_info, page)
    donation = Donation.new(:content_module => self,
        :action_page => page,
        :user => user,
        :currency => action_info[:currency],
        :amount_in_cents => action_info[:amount].to_i,
        :payment_method => action_info[:payment_method].to_sym,
        :email => action_info[:email],
        :order_id => action_info[:order_id],
        :transaction_id => action_info[:transaction_id],
        :subscription_id => action_info[:subscription_id],
        :subscription_amount =>action_info[:subscription_amount].to_i,
        :active => action_info[:confirmed],
        :frequency => action_info[:frequency].to_sym)
    donation.save!
    donation
  end

  def suggested_amounts_list(currency_iso_code)
    self.options['suggested_amounts'][currency_iso_code].split(",").map(&:to_f)
  end

  def only_allow_one_off_payment?
    frequency_options['one_off'] == 'default' && frequency_options.except('one_off').all? { |frequency, option| option == 'hidden' }
  end

  def available_frequencies_for_select
    frequency_options.reject { |frequency, option| option == 'hidden' }.map { |frequency, option| [FREQUENCY_LABELS[frequency.to_sym], frequency] }
  end

  def default_frequency
    frequency_options.find { |frequency, option| option == 'default' }.try(:first).try(:to_sym)
  end

  def default_frequency=(new_default_frequency)
    frequency_options.each do |frequency, option|
      if new_default_frequency.to_s == frequency
        new_option = 'default'
      elsif option == 'default'
        new_option = 'optional'
      else
        new_option = option
      end
      frequency_options[frequency] = new_option
    end
  end

  def amount_raised_in_cents
    @amount_raised_in_cents ||= donations.joins(:transactions).where("transactions.successful" => true).sum("transactions.amount_in_cents")
  end

  def amount_raised_in_dollars
    amount_raised_in_cents.to_f / 100
  end

  def is_a_future_recurring_payment?
    !self.commence_donation_at.blank?
  end

  def can_remove_from_page?
    false
  end

  def default_currency_set_for_at_least_a_frequency
    if default_frequency == :one_off
      self.errors.add(:default_currency, 'must be set if default frequency is one-off') if default_currency.nil? || default_currency.try(:empty?)
    else
      self.errors.add(:recurring_default_currency, 'must be set if default frequency is recurring') if recurring_default_currency.nil? || recurring_default_currency.try(:empty?)
    end
  end

  def suggested_and_default_amount_for_at_least_one_currency
    self.errors.add(:base, "A Suggested and Default amount is required for at least one currency for one-off donations.") if suggested_amounts_empty?
  end
  
  def recurring_suggested_and_default_amount_for_at_least_one_currency
    self.errors.add(:base, "A Suggested and Default amount is required for at least one currency for recurring donations.") if recurring_suggested_amounts_empty?
  end

  def all_suggested_amounts_are_greater_than_zero
    invalid_suggested_amount_currencies = suggested_amounts.keys.select do |currency|
      suggested_amounts_list(currency).any? { |x| x <= 0 }
    end.map(&:upcase)
    self.errors.add(:suggested_amounts, "for #{invalid_suggested_amount_currencies.join(', ')} must be greater than zero.") unless invalid_suggested_amount_currencies.empty?
  end

  def default_amount_is_one_of_the_suggested_amounts
    invalid_default_amount_currencies = suggested_amounts.keys.select do |currency|
      suggested_amounts = suggested_amounts_list(currency)
      !suggested_amounts.blank? && !suggested_amounts.include?(default_amount[currency].to_f)
    end.map(&:upcase)
    self.errors.add(:default_amount, "for #{invalid_default_amount_currencies.join(', ')} must be one of the suggested amounts.") unless invalid_default_amount_currencies.empty?
  end

  def recurring_default_amount_is_one_of_the_recurring_suggested_amounts
    recurring_suggested_amounts.each do |frequency, currencies_and_amounts|
      currencies_and_amounts.each do |currency, amounts|
        amounts_array = amounts.split(',').map(&:to_f)
        default_amount = recurring_default_amount.try(:[], frequency).try(:[], currency)
        default_amount = default_amount.blank? ? default_amount : default_amount.to_f
        unless amounts_array.blank? || amounts_array.include?(default_amount)
          self.errors.add(:recurring_default_amount, "for #{frequency.titleize} #{currency.upcase} must be one of the suggested amounts.")
        end
      end
    end
  end

  def one_frequency_option_must_be_the_default
    default_count = 0
    frequency_options.each { |frequency, option| default_count += 1 if option == "default" }
    self.errors.add(:frequency_options, "must have a single default selected.") unless default_count == 1
  end

  def active?
    active == 'true'
  end

  private

  def defaults
    self.button_text = I18n.t('models.donation_module.default_donate_text', :locale => (self.language.nil? ? :en : self.language.iso_code.to_sym)) unless self.button_text
    self.suggested_amounts = {} if self.suggested_amounts.blank?
    self.default_amount = {} if self.default_amount.blank?
    self.recurring_suggested_amounts = {} if self.recurring_suggested_amounts.blank?
    self.recurring_default_amount = {} if self.recurring_default_amount.blank?
    self.frequency_options = {'one_off' => 'default', 'weekly' => 'hidden', 'monthly' => 'optional', 'annual' => 'hidden'} unless self.frequency_options
    self.receipt_frequency = :once unless self.receipt_frequency
    self.public_activity_stream_template = "{NAME|A member}, {COUNTRY|}<br/>[{HEADER}]" unless self.public_activity_stream_template
    self.active = 'true' unless self.active
  end

  def remove_whitespace_from_suggested_amounts
    self.suggested_amounts.each { |k, v| self.suggested_amounts[k] = remove_whitespace(v) }
  end

  def remove_whitespace_from_recurring_suggested_amounts
    self.recurring_suggested_amounts.each do |frequency, currency_and_amounts|
      currency_and_amounts.each do |currency, amounts|
        self.recurring_suggested_amounts[frequency][currency] = remove_whitespace(amounts)
      end
    end
  end

  def make_all_configured_frequencies_optional
    if frequency_options['one_off'] == 'hidden'
      frequency_options['one_off'] = 'optional' if !suggested_amounts.try(:empty?) && !default_currency.try(:blank?) && !default_amount.try(:empty?)
    end
    if frequency_options['monthly'] == 'hidden'
      frequency_options['monthly'] = 'optional' if !recurring_suggested_amounts.try(:empty?) && !recurring_default_amount.try(:blank?) && !recurring_default_currency.try(:empty?)
    end
  end

  def remove_whitespace(string)
    string.gsub(/\s+/, '')
  end

  def count_donations_made
    pages.first ? Donation.where(:page_id => pages.first.id).count : 0
  end

  def suggested_amounts_empty?
    suggested_amounts.select {|currency, amounts| !currency.blank? && !amounts.blank? && !default_amount[currency].blank?}.empty?
  end

  def recurring_suggested_amounts_empty?
    recurring_suggested_amounts.select {|currency, amounts| !currency.blank? && !amounts.blank? && !recurring_default_amount[currency].blank?}.empty?
  end

  def one_off?
    default_frequency == :one_off || default_currency.present?
  end

  def recurring?
    [:weekly, :monthly, :annual].include?(default_frequency) || recurring_default_currency.present?
  end
end
