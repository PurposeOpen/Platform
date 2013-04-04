module ListCutter
  class ActivityCountRule < Rule
    OPERATORS = [
      ['More Than', 'more_than'],
      ['Less Than', 'less_than'],
      ['Equal to', 'equal_to']
    ]

    OPERATOR_RULE_MAPPING = {
      true  => {'more_than' => '<=', 'less_than' => '>=', 'equal_to' => '<>'},
      false => {'more_than' => '>', 'less_than' => '<', 'equal_to' => '='}
    }

    def active?; true; end

    def to_relation
      User.joins("LEFT OUTER JOIN (#{self.to_sql}) tmp ON users.id = tmp.user_id").where(self.filter_sql("tmp"))
    end

    def create_sql
      "CREATE TEMPORARY TABLE %s (user_id INT, activity_count INT, PRIMARY KEY (user_id, activity_count)) %s" % [ table_name, to_sql ]
    end

    def join_sql(table_name = self.table_name)
      "LEFT OUTER JOIN %s ON users.id = %s.user_id" % [ table_name, table_name ]
    end

    def filter_sql(table_name = self.table_name)
      operator = OPERATOR_RULE_MAPPING[negate?][range_operator]
      "IFNULL(%s.activity_count, 0) %s %d" % [ table_name, operator, activity_count.to_i ]
    end

  end
end
