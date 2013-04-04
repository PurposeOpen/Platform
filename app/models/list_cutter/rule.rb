require 'yaml'

module ListCutter
  class Rule
    include ActiveModel::Validations
    def self.fields(*fields)
      fields = fields.map(&:to_sym)
      fields.each do |field|
        define_method "#{field}" do
          @params[field]
        end
        define_method "#{field}=" do |value|
          @params[field] = value
        end
      end
    end

    def self.code
      self.name.demodulize.underscore
    end

    def negate?
      !!@params[:not]
    end

    def can_negate?
      true
    end

    def sanitize_sql(*args)
      ActiveRecord::Base.send(:sanitize_sql_array, args).squish
    end

    def initialize(params={})
      @params = params.symbolize_keys
      @movement = params[:movement]
    end

    def to_yaml(opts = {})
      {self.class.code => @params}.to_yaml(opts)
    end

    def as_json(options = {})
      {self.class.code => @params}
    end

    def to_human_sql
      self.class.name.demodulize.underscore.humanize + " (no description)"
    end

    def to_relation
      User.where("id IN (#{self.to_sql})")
    end

    def table_name
      "tmp_list_query_%s" % [ to_sql.hash.to_s.gsub("-", "_") ]
    end

    def drop_sql
      "DROP TEMPORARY TABLE IF EXISTS %s;" % [ table_name ]
    end

    def create_sql
      "CREATE TEMPORARY TABLE %s (user_id INT PRIMARY KEY) %s;" % [ table_name, to_sql ]
    end

    def join_sql(table_name = self.table_name)
      "%s JOIN %s ON users.id = %s.user_id" % [ negate? ? "LEFT OUTER" : 'INNER', table_name, table_name ]
    end

    def filter_sql(table_name = self.table_name)
      negate? ? "%s.user_id IS NULL" % [ table_name ] : nil
    end

    protected

    def is_clause
      negate? ? 'is not' : 'is'
    end

    def in_clause
      negate? ? 'not in' : 'in'
    end
  end
end
