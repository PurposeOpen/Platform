# == Schema Information
#
# Table name: list_intermediate_results
#
#  id         :integer          not null, primary key
#  data       :text
#  ready      :boolean          default(FALSE)
#  list_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  rules      :text
#

class ListIntermediateResult < ActiveRecord::Base
  include RulesSerializable

  belongs_to :list
  serialize :data, JSON
  serialize :rules, JSON

  delegate :movement, to: :list, allow_nil: true

  def user_count
    data['number_of_selected_users'] if data
  end

  def summary
    data.try(:with_indifferent_access)
  end

  def timed_query(&block)
    start = Time.now
    result = block.call
    elapsed_time = Time.now - start
    return elapsed_time, result
  end

  def update_results!
    results_table = []

    languages_hash = list.count_by_rules_excluding_users_from_push(rules) do |description, sql, time|
      results_table << [ description, sql, time ]
    end

    self.update_attributes!(ready: true, data: {
      sql: list.count_by_language_relation.to_sql,
      results_table: results_table,
      number_of_selected_users: languages_hash.values.sum,
      number_of_selected_users_by_language: languages_hash
    })
  rescue => e
    self.update_attributes! ready: true, data: { error_message: e.message, error_backtrace: e.backtrace }
  end

  def update_results_from_sent_email!(email, members_sent_count)
    if data
      data['number_of_selected_users'] -= members_sent_count
      data['number_of_selected_users_by_language'][email.language.name] -= members_sent_count if data['number_of_selected_users_by_language'][email.language.name]

      self.save
    end
  end
end
