class ExcelTransactionsReport < ReportTable
  def self.columns
    [
      "Donation ID", "Txn ID", "Member ID", "Member Email",
      "Txn Status", "Amount", "Txn Date", "Settlement Date", "Payment Method",
      "Cheque Number", "Cheque Name", "Cheque Bank", "Cheque Branch",
      "Frequency", "Campaign", "Action Sequence", "Page"
    ]
  end

  def initialize(transactions)
    @transactions = transactions
  end
  
  def rows
    @transactions.inject([]) { |rows, txn| rows << row_for(txn); rows }
  end
  
  def row_for(txn)
    payment_method = txn.payment_method == "credit_card" ? txn.card_type : txn.payment_method
    
    [
      txn.donation_id,
      txn.txn_id,
      txn.user_id,
      txn.email,
      
      txn.successful? ? "Successful" : "Failed",
      number_to_currency(txn.amount_in_dollars),
      txn.created_at,
      txn.settled_on,
      (payment_method || "").titlecase,
      
      txn.cheque_number,
      txn.cheque_name,
      txn.cheque_bank,
      txn.cheque_branch,

      txn.frequency.titlecase,
      !txn.campaign_name.blank? ? txn.campaign_name : "",
      !txn.action_sequence_name.blank? ? txn.action_sequence_name : "",
      !txn.page_name.blank? ? txn.page_name : "",
    ]
  end
end