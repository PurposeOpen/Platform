# == Schema Information
#
# Table name: lists
#
#  id                           :integer          not null, primary key
#  rules                        :text             default(""), not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  blast_id                     :integer
#  saved_intermediate_result_id :integer
#

class List < ActiveRecord::Base
  include RulesSerializable

  serialize :rules, JSON

  validate :internal_rules
  validates_presence_of :blast_id

  has_many :list_intermediate_results
  belongs_to :saved_intermediate_result, class_name: 'ListIntermediateResult'
  belongs_to :blast

  delegate :movement, :list_cuttable?, to: :blast, allow_nil: true
  delegate :summary, :user_count, to: :saved_intermediate_result, allow_nil: true

  def self.build(params)
    List.where(:id => params[:list_id]).first_or_initialize(:blast => Blast.find(params[:blast_id])).tap do |list|
      list.rules.clear
      (params[:rules] || [] ).each do |rule_type, rules_of_the_same_type|
        rules_of_the_same_type.each do |rule_index, rule_params|
          next unless rule_params[:activate] == "1"
          rule_params[:not] = (rule_params[:not] == "true")
          list.add_rule rule_type, rule_params.except(:activate)
        end
      end
    end
  end

  def count_by_rules_excluding_users_from_push(rules=self.rules, &block)
    final_result = execute_query(:select_all, self.count_by_language_relation, rules, &block)
    
    languages = Language.all.index_by(&:id)
    final_result.inject({}) do |h, row|
      language_name = languages[row['language_id']].try(:name) || "Unknown"
      h.merge! language_name => row['user_count']
    end
  end

  def filter_by_rules_excluding_users_from_push(email, options={}, &block)
    options[:no_jobs]         ||= 1

    relation = self.list_relation
    relation = partition_users_by_job_id(relation, options[:no_jobs], options[:current_job_id]) if options[:no_jobs] > 1
    relation = filter_users_by_language(relation, email)

    if options[:limit].is_a? Fixnum
      relation = relation.order(:random).limit(options[:limit])
    end

    execute_query :select_values, relation, self.rules, &block
  end

  def count_by_language_relation
    User.select("users.language_id, COUNT(users.id) AS user_count").
      where(is_member: true).
      where(movement_id: movement.id).
      group("users.language_id")
  end

  def list_relation
    User.select("DISTINCT users.id").
      where(is_member: true).
      where(movement_id: movement.id)
  end

  private

  # Yields to given block once per query executed with description, SQL, and elapsed time.
  def execute_query(selection_type, relation, rules, &block)
    rules_with_excluded_users = []
    begin
      exclude_users_rule = ListCutter::ExcludeUsersRule.new push_id: self.blast.push.id, movement: movement
      rules_with_excluded_users = self.rules + [ exclude_users_rule ]

      create_tables! rules_with_excluded_users, &block

      final_relation = rules_with_excluded_users.inject(relation) do |rel, rule|
        rel.joins(rule.join_sql).where(rule.filter_sql)
      end

      sql = final_relation.to_sql

      total_time, total_result = measure { ReadOnly.connection.send(selection_type, sql) }
      block.call "Combined query", sql, total_time unless block.nil?
      total_result
    ensure
      drop_tables! rules_with_excluded_users
    end
  end

  def partition_users_by_job_id(relation, no_jobs, current_job_id)
    relation.select("MOD(users.id, #{no_jobs}) modulus").having("modulus = #{current_job_id || 0}")
  end

  def filter_users_by_language(relation, email)
    relation.where(:language_id => email.language_id)
  end

  def internal_rules
    rules.each do |rule|
      errors.add(get_key(rule), rule.errors.messages) if rule.invalid?
    end
  end

  def get_key(rule)
    rule.class.name.underscore.split("/")[1].to_sym
  end
 
  def create_tables!(rules=self.rules, &block)
    rules.each do |rule|
      elapsed_time, result = measure { ReadOnly.connection.execute rule.create_sql }

      block.call rule.to_human_sql, rule.to_sql, elapsed_time unless block.nil?
    end
  end

  def drop_tables!(rules=self.rules)
    rules.each do |rule|
      ReadOnly.connection.execute rule.drop_sql
    end
  end

  def measure(&block)
    start = Time.now
    result = block.call
    elapsed_time = Time.now - start
    return elapsed_time, result
  end
end
