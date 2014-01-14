module ListCutter
  class RecurringDonationAmountRule < Rule
    OPERATORS = [
        ['More Than', 'more_than'],
        ['Less Than', 'less_than'],
        ['Equal to', 'equal_to']
    ]

    OPERATOR_RULE_MAPPING = {
        'more_than' => '>=',
        'less_than' => '<=',
        'equal_to' => '=',
        }

    fields :amount
    validates_presence_of :amount, :message => 'Please specify an amount in dollar cents'

    def amount_in_dollars
      amount.nil? ?  0.0 : amount / 100.0
    end

    def amount_in_dollars=(dollars)
      self.amount = dollars.to_f * 100.0
    end

    def initialize(params={})
      super(params)

      # set virtual attribute to initialize 'amount' value
      if params.has_key?(:amount_in_dollars) && !params.has_key?(:amount)
        self.amount_in_dollars = params[:amount_in_dollars]
      end
    end

    def operators
      OPERATORS
    end

    def query_operator
      mapped_operator = OPERATOR_RULE_MAPPING[@params[:operator]]
      raise "No operator found" if (mapped_operator.nil?)
      mapped_operator
    end

    def to_sql
      sanitize_sql <<-SQL, amount
        SELECT user_id
        FROM donations
        WHERE donations.active = 1
        AND donations.frequency != 'one_off'
        AND donations.subscription_amount #{query_operator} ?
        GROUP BY user_id
      SQL
    end

    def active?
      true
    end

    def to_human_sql
      "Donation amount #{is_clause} #{query_operator} #{amount}"
    end
  end
end
