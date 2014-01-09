require 'spec_helper'

describe "spreedly_client" do
  let(:successful_payment_method_response) { successful_payment_method_response_xml }
  let(:failed_payment_method_response) { failed_payment_method_response_xml }
  let(:successful_purchase_response) { successful_purchase_response_xml }
  let(:failed_purchase_response) { failed_purchase_response_xml }
  let(:spreedly_client) { SpreedlyClient.new '501-c-3' }

  before :each do
    Spreedly::Environment.stub(:new) { nil }
  end

  describe ".payment_method_to_hash" do
    it "should build payment_method as a hash" do
      payment_method = Spreedly::PaymentMethod.new_from(Nokogiri::XML(successful_payment_method_response))
      payment_method = spreedly_client.payment_method_to_hash(payment_method)

      payment_method[:token].should == 'CATQHnDh14HmaCrvktwNdngixMm'
    end
  end

  describe ".transaction_to_hash" do
    it "should build transaction as a hash" do
      spreedly_transaction = Spreedly::Transaction.new_from(Nokogiri::XML(successful_purchase_response))
      transaction = spreedly_client.transaction_to_hash(spreedly_transaction)

      transaction[:token].should == 'CtK2hq1rB9yvs0qYvQz4ZVUwdKh'
      transaction[:payment_method][:token].should == 'SvVVGEsjBXRDhhPJ7pMHCnbSQuT'
    end
  end

  describe ".retrieve_and_hash_payment_method" do
    it "should return payment_method as a hash with a classification key" do
      @spreedly.stub(:find_payment_method) { Spreedly::PaymentMethod.new_from(Nokogiri::XML(successful_payment_method_response)) }
      payment_method = spreedly_client.retrieve_and_hash_payment_method('CATQHnDh14HmaCrvktwNdngixMm')

      payment_method[:token].should == 'CATQHnDh14HmaCrvktwNdngixMm'
      payment_method[:data][:classification].should == '501-c-3'
    end

    it "should return a hash with an error code and message if unable to find payment method" do
      @spreedly.stub(:find_payment_method).and_raise Spreedly::XmlErrorsList.new(Nokogiri::XML(failed_payment_method_response))
      payment_method = spreedly_client.retrieve_and_hash_payment_method('nonexistent_payment_method_token')

      payment_method[:code] == 422
      payment_method[:errors][:message].should == "Unable to find the specified payment method."
    end
  end

  describe ".purchase_and_hash_response" do
    let(:payment_method) do
      { :token=>"CATQHnDh14HmaCrvktwNdngixMm",
        :created_at=>'2013-12-21 12:51:47 UTC',
        :updated_at=>'2013-12-21 12:51:47 UTC',
        :email=>"frederick@example.com",
        :storage_state=>"cached",
        :data=>{
          :classification=>"501-c-3",
          :currency=>'USD',
          :frequency=>'weekly',
          :amount=>'2000'
        },
        :first_name=>"Bob",
        :last_name=>"Smith",
        :full_name=>"Bob Smith",
        :month=>"1",
        :year=>"2020",
        :number=>"XXXX-XXXX-XXXX-1111",
        :last_four_digits=>"1111",
        :card_type=>"visa",
        :verification_value=>"XXX",
        :address1=>"345 Main Street",
        :address2=>"Apartment #7",
        :city=>"Wanaque",
        :state=>"NJ",
        :zip=>"07465",
        :country=>"United States",
        :phone_number=>"201-332-2122" }
    end

    it "should return purchase as a hash with the payment_method" do
      @spreedly.stub(:purchase_on_gateway) { Spreedly::Transaction.new_from(Nokogiri::XML(successful_purchase_response)) }
      purchase = spreedly_client.purchase_and_hash_response(payment_method)

      purchase[:token].should == 'CtK2hq1rB9yvs0qYvQz4ZVUwdKh'
      purchase[:payment_method][:token] == 'CATQHnDh14HmaCrvktwNdngixMm'
    end

    it "should return a hash with an error code, message, and payment method info on failure to purchase" do
      @spreedly.stub(:purchase_on_gateway).and_raise Spreedly::XmlErrorsList.new(Nokogiri::XML(failed_purchase_response))
      purchase = spreedly_client.purchase_and_hash_response(payment_method)

      purchase[:code].should == 422
      purchase[:errors][:message].should == "First name can't be blank"
      purchase[:payment_method][:email] == 'frederick@example.com'
    end
  end

  describe ".create_payment_method_and_purchase" do
    it "should return payment method and not attempt to purchase if the payment method has errors" do
      @spreedly.stub(:find_payment_method).and_raise Spreedly::XmlErrorsList.new(Nokogiri::XML(failed_payment_method_response))
      payment_method = spreedly_client.retrieve_and_hash_payment_method('nonexistent_payment_method_token')

      spreedly_client.should_not_receive(:purchase_and_hash_response)
      result = spreedly_client.create_payment_method_and_purchase('nonexistent_payment_method_token')
      result.should == payment_method
    end

    it "should call purchase if the payment method has no errors" do
      @spreedly.stub(:find_payment_method) { Spreedly::PaymentMethod.new_from(Nokogiri::XML(successful_payment_method_response)) }
      spreedly_client.retrieve_and_hash_payment_method('CATQHnDh14HmaCrvktwNdngixMm')

      spreedly_client.should_receive(:purchase_and_hash_response)
      spreedly_client.create_payment_method_and_purchase('CATQHnDh14HmaCrvktwNdngixMm')
    end
  end
end
