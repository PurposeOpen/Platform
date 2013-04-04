class ExcelGroupedTransactionsReport < ReportTable
  @@field_column_map = {
    :year => "Year",
    :month => "Month",
    :campaign_name => "Campaign",
    :frequency => "Frequency",
    :total => "Total",
  }

  def self.columns
    @@default_columns
  end

  def initialize(transactions)
    init_columns(transactions)
    @transactions = transactions
  end

  def init_columns(transactions)
    transaction = transactions.first
    @@default_columns = @@field_column_map.keys.inject([]) do |acc,field|
      acc << @@field_column_map[field] if transaction.respond_to?(field)
      acc
    end
  end
  private :init_columns

  def rows
    @transactions.inject([]) { |rows, txn| rows << row_for(txn); rows }
  end
  
  def row_for(txn)
    @@field_column_map.keys.inject([]) do |acc,field|
      acc << txn.send(field) if txn.respond_to?(field)
      acc
    end
  end
end