# == Schema Information
#
# Table name: campaigns
#
#  id            :integer          not null, primary key
#  name          :string(64)
#  description   :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  deleted_at    :datetime
#  created_by    :string(255)
#  updated_by    :string(255)
#  alternate_key :integer
#  opt_out       :boolean          default(TRUE)
#  movement_id   :integer
#  slug          :string(255)
#

class Campaign < ActiveRecord::Base
  extend FriendlyId
  include CacheableModel
  include QuickGoable

  acts_as_paranoid
  acts_as_user_stampable
  belongs_to :movement
  has_many :action_sequences, dependent: :destroy
  has_many :pushes, dependent: :destroy
  has_many :get_togethers

  friendly_id :name, use: :slugged

  validates_length_of :name, maximum: 64, minimum: 3

  def cache_key
    self.class.generate_cache_key(self.friendly_id)
  end

  def self.select_options(movement)
    self.select("id, name").where(movement_id: movement.id).inject([]) do |acc, campaign|
      acc << [campaign.name, campaign.id]
      acc
    end
  end

  def build_stats_query
    ask_content_modules  = ['NonTaxDeductibleDonationModule', 'TaxDeductibleDonationModule', 'DonationModule', 'PetitionModule', 'JoinModule', 'EmailMPModule', 'EmailTargetsModule']
    reported_activities  = ["action_taken", "subscribed"]
    action_sequences     = Arel::Table.new(:action_sequences, as: 'action_sequences')
    pages                = Arel::Table.new(:pages, as: 'pages')
    content_module_links = Arel::Table.new(:content_module_links, as: 'content_module_links')
    content_modules      = Arel::Table.new(:content_modules, as: 'content_modules')
    user_activity_events = Arel::Table.new(:user_activity_events, as: 'user_activity_events')

    projections = [
      content_modules[:created_at],
      action_sequences[:name].as("action_sequence_name"),
      pages[:name].as("page_name"),
      content_modules[:type],
      content_modules[:id].as("content_module_id"),
      Arel::SqlLiteral.new(%Q{COALESCE(SUM(`user_activity_events`.`activity` = 'action_taken'), 0) AS actions_taken}),
      Arel::SqlLiteral.new(%Q{COALESCE(SUM(`user_activity_events`.`activity` = 'subscribed' AND
      (`user_activity_events`.`content_module_type` = 'JoinModule' OR `user_activity_events`.`content_module_type` = 'PetitionModule')), 0) AS subscriptions}),
      Arel::SqlLiteral.new(%Q{COUNT(`user_activity_events`.`id`) AS total_events}),
      pages[:id].as("page_id")
    ]

    relation = action_sequences.
        project(projections).
        join(pages).on(pages[:action_sequence_id].eq(action_sequences[:id]), pages[:live_page_id].eq(nil)).
        join(content_module_links).on(content_module_links[:page_id].eq(pages[:id])).
        join(content_modules).on(content_modules[:id].eq(content_module_links[:content_module_id]),
            content_modules[:type].in(ask_content_modules)).
        join(user_activity_events, Arel::Nodes::OuterJoin).on(user_activity_events[:content_module_id].eq(content_modules[:id]),
            user_activity_events[:activity].in(reported_activities), user_activity_events[:user_response_type].not_eq('Transaction').or(user_activity_events[:user_response_type].eq(nil)))

    relation = relation.where(action_sequences[:campaign_id].eq(self.id)).group(pages[:id])
    relation.order(action_sequences[:created_at].desc).to_sql
  end

end
