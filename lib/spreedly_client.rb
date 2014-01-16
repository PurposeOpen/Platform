class SpreedlyClient
  def initialize(classification)
    @classification = classification
    if classification == '501-c-3'
      @spreedly = Spreedly::Environment.new(ENV['SPREEDLY_501C3_ENV_KEY'], ENV['SPREEDLY_501C3_APP_ACCESS_SECRET'])
    else
      @spreedly = Spreedly::Environment.new(ENV['SPREEDLY_501C4_ENV_KEY'], ENV['SPREEDLY_501C4_APP_ACCESS_SECRET'])
    end
  end

  def create_payment_method_and_purchase(payment_method_token)
    payment_method = retrieve_and_hash_payment_method(payment_method_token)
    return payment_method if payment_method[:errors]
    purchase_and_hash_response(payment_method)
  end

  def retrieve_and_hash_payment_method(payment_method_token)
    spreedly_payment_method = @spreedly.find_payment_method(payment_method_token)
    payment_method = payment_method_to_hash(spreedly_payment_method)
    classify_payment_method(payment_method)
  rescue Spreedly::Error => e
    { :code => 404, :errors => e.errors.first }
  end

  def purchase_and_hash_response(payment_method)
    gateway_token = get_gateway_token(payment_method[:data][:currency])
    spreedly_transaction = @spreedly.purchase_on_gateway(gateway_token, payment_method[:token], payment_method[:data][:amount], retain_on_success: true)
    transaction_to_hash(spreedly_transaction)
  rescue Spreedly::Error => e
    { :code => 422, :errors => e.errors.first, :payment_method => payment_method }
  end

  def get_gateway_token(currency)
    case currency.downcase
    when 'usd'
      # TODO: remove hard-coded test gateway token in constants.yml
      # AppConstants.spreedly_gateway_token_usd
      AppConstants.spreedly_gateway_token_test
    when 'cad'
      AppConstants.spreedly_gateway_token_cad
    when 'eur'
      AppConstants.spreedly_gateway_token_eur
    when 'gbp'
      AppConstants.spreedly_gateway_token_gbp
    end
  end

  def payment_method_to_hash(spreedly_payment_method)
    # To parse payment_method data, we need to wrap it in an element for Nokogiri
    payment_method_data = Nokogiri::XML("<root>#{spreedly_payment_method.data}</root>")
    root_element = payment_method_data.children.first
    payment_method_data = root_element.children.map do |x|
      { x.name.to_sym => x.text }
    end.reduce(&:merge)
    payment_method = spreedly_payment_method.field_hash
    payment_method[:data] = payment_method_data
    payment_method
  end

  def transaction_to_hash(spreedly_transaction)
    payment_method = classify_payment_method(payment_method_to_hash(spreedly_transaction.payment_method))
    transaction = spreedly_transaction.field_hash
    transaction[:payment_method] = payment_method
    transaction
  end

  private

  def classify_payment_method(payment_method)
    payment_method[:data][:classification] = @classification
    payment_method
  end
end
