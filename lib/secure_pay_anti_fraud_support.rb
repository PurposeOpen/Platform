
module SecurePayAntiFraudSupport
  TEST_ANTI_FRAUD_URL="https://test.securepay.com.au/antifraud/payment"
  LIVE_ANTI_FRAUD_URL="https://www.securepay.com.au/antifraud/payment"

  def self.included(mod)
    mod::TRANSACTIONS.merge!(anti_fraud_purchase: 0)
  end

  def purchase_with_anti_fraud(money, credit_card, options = {})
    commit_anti_fraud_purchase(build_anti_fraud_purchase_request(money, credit_card, options))
  end

  def build_anti_fraud_purchase_request(money, credit_card, options)
    xml = Builder::XmlMarkup.new

    xml.tag! 'amount', amount(money)
    xml.tag! 'currency', options[:currency] || currency(money)
    xml.tag! 'purchaseOrderNo', options[:order_id].to_s.gsub(/[ ']/, '')

    xml.tag! 'CreditCardInfo' do
      xml.tag! 'cardNumber', credit_card.number
      xml.tag! 'expiryDate', expdate(credit_card)
      xml.tag! 'cvv', credit_card.verification_value if credit_card.verification_value?
    end

    xml.tag! 'BuyerInfo' do
      xml.tag! 'firstName', options[:first_name] if options[:first_name]
      xml.tag! 'lastName', options[:last_name] if options[:last_name]
      xml.tag! 'zipCode', options[:zip_code] if options[:zip_code]
      xml.tag! 'town', options[:town] if options[:town]
      xml.tag! 'billingCountry', options[:billing_country] if options[:billing_country]
      xml.tag! 'deliveryCountry', options[:billing_country] if options[:billing_country]
      xml.tag! 'emailAddress', options[:email] if options[:email]
      xml.tag! 'ip', options[:ip] if options[:ip]
    end
    xml.target!
  end
  private :build_anti_fraud_purchase_request

  def commit_anti_fraud_purchase(request)
    endpoint = test? ? TEST_ANTI_FRAUD_URL : LIVE_ANTI_FRAUD_URL
    request_xml = build_request(:anti_fraud_purchase, request)
    response = ssl_post(endpoint, request_xml)
    Rails.logger.info "Payment Gateway Request (AntiFraud): #{filter_sensitive_data(request_xml).inspect}"
    Rails.logger.info "Payment Gateway Response (AntiFraud): #{response.inspect}"
    response = parse(response)

    ActiveMerchant::Billing::Response.new(success?(response), message_from(response), response,
                 test: test?,
                 authorization: authorization_from(response)
    )
  end
  private :commit_anti_fraud_purchase

  def filter_sensitive_data(request_xml)
    safe_request = request_xml.gsub(/cardNumber>\d(\d{11})/) {|m| "cardNumber>#{m[11]}#{'X' * 11}"}
    safe_request.gsub(/cvv>\d{3}/) {|m| "cvv>#{'X' * 3}"}
  end

end
