require 'csv'

class ReportTable
  include ActionView::Helpers::NumberHelper

  def full_rows
    self.rows.map do |row|
      column_index = 0

      self.class.columns.inject({}) do |row_hash, column|
        row_hash[column] = row[column_index]
        column_index += 1
        row_hash
      end
    end
  end
    
  def to_csv
    CSV.generate do |csv|
      csv << self.class.columns
      self.rows.each do |row|
        csv << row
      end
    end
  end
end