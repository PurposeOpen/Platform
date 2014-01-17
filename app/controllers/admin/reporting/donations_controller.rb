module Admin
  class Reporting::DonationsController < AdminController
    layout 'movements'

    def index
      if params[:start_date] && params[:end_date]
        start_date = Date.strptime("#{params[:start_date]['start_date(1i)']}-#{params[:start_date]['start_date(2i)']}-#{params[:start_date]['start_date(3i)']}").beginning_of_day
        end_date = Date.strptime("#{params[:end_date]['end_date(1i)']}-#{params[:end_date]['end_date(2i)']}-#{params[:end_date]['end_date(3i)']}").end_of_day
      end

      @transactions = Transaction.where('created_at >= ? AND created_at <= ?', start_date, end_date).includes(:donation)
      @transactions_by_currency = []
      @transactions.group_by(&:currency).each do |currency, transactions|
        transactions_count = transactions.count
        transactions_sum = transactions.sum { |t| t.amount_in_cents }
        @transactions_by_currency << { :currency => currency, :amount_in_cents => transactions_sum, :count => transactions_count }
      end
    end
  end
end
