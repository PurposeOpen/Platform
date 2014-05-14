class ReportFilter

  # pagination
  attr_accessor :page, :order_by, :order_direction

  # date filters (date type is created_at, settled_on, etc)
  attr_accessor :on_date, :before_date, :after_date, :date_type

  def initialize params={}
    params.each do |key,value|
      self.send("#{key}=".to_sym, value)
    end
  end

  def filter
    conds = {}
    conds << { condtions: conditions_clause} unless conditions_clause.empty?
    conds << { order: order_lcause} unless order_clause.empty?
  end

  def conditions_clause
    conds = {}
    conds << integer_clauses unless order_clause.blank?
  end

  def order_clause
    raise 'Missing order field' if order_direction && order_by.nil?
    raise 'Invalid direction' unless [nil, 'DESC', 'ASC'].include?(order_direction)
    expr = [order_by, order_direction].compact.join(' ')
    expr.blank? ? nil : ({order: expr })
  end

  def integer_clauses
    fields = [:page].collect do |field|
      [field, send(field)]
    end
    Hash[fields]
  end

  def get_transactions
    Transaction.find(:all, conditions: :conditions, order: order)
  end
end
