# == Schema Information
#
# Table name: transactions
#
#  id              :integer          not null, primary key
#  donation_id     :integer          not null
#  successful      :boolean          default(FALSE)
#  amount_in_cents :integer
#  response_code   :string(255)
#  message         :string(255)
#  txn_ref         :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  currency        :string(3)
#

class Transaction < ActiveRecord::Base
  
  belongs_to :donation
  
  scope :successful, where(:successful => true)
  
  after_create :create_activity_event_on_success
  
  def amount_in_dollars
    self.amount_in_cents.to_f / 100
  end

  def self.filter_by(options={})
    options = cleanup(options)
    projections = unless options[:group_by].blank?
      projections_for_group_by(options[:group_by])
    else
      default_projections
    end

    transactions = Transaction.select(projections).
        joins(:donation => :user).
        joins("LEFT OUTER JOIN pages ON pages.id = donations.page_id").
        joins("LEFT OUTER JOIN action_sequences ON action_sequences.id = pages.action_sequence_id").
        joins("LEFT OUTER JOIN campaigns ON campaigns.id = action_sequences.campaign_id")


    if options.blank?
      transactions = transactions.where(:transactions => {:created_at => 1.week.ago..Time.now})
    elsif !(options[:from_date].blank? || options[:to_date].blank?)
      from_date = options[:from_date].is_a?(String) ? DateTime.parse(options[:from_date]) : options[:from_date]
      to_date = options[:to_date].is_a?(String) ? DateTime.parse(options[:to_date]) : options[:to_date]
      transactions = transactions.where(:transactions => {:created_at => from_date..to_date})
    end

    
    transactions = transactions.where(:transactions => {:id => options[:id]}) unless options[:id].blank?
    transactions = transactions.where(:users => {:id => options[:user_id]}) unless options[:user_id].blank?

    transactions = transactions.where(donations: {payment_method: options[:payment_methods]}) unless options[:payment_methods].blank?
    transactions = transactions.where(successful: options[:status] == "successful" ? true : false) unless options[:status].blank?
    transactions = transactions.where(donations: {users: {email: options[:user_email]}}) unless options[:user_email].blank?

    transactions = append_group_by(transactions, options[:group_by]) unless options[:group_by].blank?
    transactions.order(:transactions => :created_at)
  end

  private

  def self.cleanup(options)
    options ||= {}
    options[:payment_methods].reject! { |e| e.blank? } unless options[:payment_methods].blank?
    options[:group_by].reject! { |e| e.blank? } unless options[:group_by].blank?
    options
  end

  def self.projections_for_group_by(group_by_options)
    projections = group_by_options.inject([]) do |acc, option|
      case option.to_sym
        when :year_month
          acc << "YEAR(transactions.created_at) as 'year'" << "MONTH(transactions.created_at) as 'month'"
        when :campaign
          acc << "campaigns.name AS 'campaign_name'"
        when :frequency
          acc << "donations.frequency"
      end
      acc
    end
    projections << "SUM(transactions.amount_in_cents) as 'total'"
    projections.join(",")
  end

  def self.default_projections
    <<PROJECTIONS
  transactions.id AS 'txn_id',
  transactions.amount_in_cents,
  transactions.successful,
  transactions.created_at,
  donations.id AS 'donation_id',
  donations.frequency,
  donations.payment_method,
  users.id AS 'user_id',
  users.email,
  campaigns.name AS 'campaign_name',
  action_sequences.name AS 'action_sequence_name',
  pages.name AS 'page_name'
PROJECTIONS
  end

  def self.append_group_by(transactions, group_by_options)
    expressions = group_by_options.inject([]) do |acc, option|
      case option.to_sym
        when :year_month
          acc << "YEAR(transactions.created_at)" << "MONTH(transactions.created_at)"
        when :campaign
          acc << "campaigns.name"
        when :frequency
          acc << "donations.frequency"
      end
      acc
    end
    transactions.group(expressions.join(","))
  end

  def create_activity_event_on_success
    UserActivityEvent.action_taken!(donation.user, donation.action_page, donation.content_module, self, donation.email) if successful?
  end
end
