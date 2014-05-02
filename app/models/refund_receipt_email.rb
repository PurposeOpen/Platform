class RefundReceiptEmail
  
  def initialize(transaction)
    @transaction = transaction
  end
  
  def send!
    Emailer.refund_receipt_email(@transaction).deliver
  end
  handle_asynchronously(:send!) unless Rails.env.test?
end