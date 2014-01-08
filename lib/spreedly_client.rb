class SpreedlyClient
  def self.create_environment(classification)
    if classification == '501-c-3'
      spreedly = Spreedly::Environment.new(ENV['SPREEDLY_501C3_ENV_KEY'], ENV['SPREEDLY_501C3_APP_ACCESS_SECRET'])
    else
      spreedly = Spreedly::Environment.new(ENV['SPREEDLY_501C4_ENV_KEY'], ENV['SPREEDLY_501C4_APP_ACCESS_SECRET'])
    end
  end

  def self.create_payment_method_and_purchase(classification, payment_method_token)
    @spreedly = self.create_environment(classification)
    payment_method = self.retrieve_and_hash_payment_method(classification, payment_method_token)
    return payment_method if payment_method[:errors]
    self.purchase_and_hash_response(payment_method)
  end

  def self.retrieve_and_hash_payment_method(classification, payment_method_token)
    payment_method = @spreedly.find_payment_method(payment_method_token)
    payment_method = self.payment_method_to_hash(payment_method)
    payment_method = self.classify_payment_method(payment_method, classification)
  rescue Spreedly::Error => e
    { :code => 404, :errors => e.errors.first }
  end

  def self.purchase_and_hash_response(payment_method)
    gateway_token = self.get_gateway_token(payment_method[:data][:currency])
    transaction = @spreedly.purchase_on_gateway(gateway_token, payment_method[:token], payment_method[:data][:amount], retain_on_success: true)
    transaction = self.transaction_to_hash(transaction, payment_method[:data][:classification])
  rescue Spreedly::Error => e
    { :code => 422, :errors => e.errors.first, :payment_method => payment_method }
  end

  def self.get_gateway_token(currency)
    case currency.downcase
    when 'usd'
      # TODO: remove hard-coded test gateway token
      'DWqZNx7SyOHZyrscU7p5gzORxky'
    end
  end

  def self.payment_method_to_hash(payment_method)
    payment_method_data = Nokogiri::XML("<root>#{payment_method.data}</root>")
    payment_method_data = payment_method_data.children.first.children.map {|x| { x.name.to_sym => x.text }}.inject({}){|hash, curr_hash| hash.merge curr_hash}
    payment_method = payment_method.field_hash
    payment_method[:data] = payment_method_data
    payment_method
  end

  def self.transaction_to_hash(transaction, classification)
    payment_method = SpreedlyClient.payment_method_to_hash(transaction.payment_method)
    payment_method = classify_payment_method(payment_method, classification)
    transaction = transaction.field_hash
    transaction[:payment_method] = payment_method
    transaction
  end

  private

  def self.classify_payment_method(payment_method, classification)
    if classification == '501-c-3'
      payment_method[:data][:classification] = '501-c-3'
    else
      payment_method[:data][:classification] = '501-c-4'
    end
    payment_method
  end
end
