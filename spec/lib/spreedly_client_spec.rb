require 'spec_helper'

describe "spreedly_client" do
  let(:successful_payment_method_response) do
    <<-XML
      <payment_method>
        <token>CATQHnDh14HmaCrvktwNdngixMm</token>
        <created_at type="datetime">2013-12-21T12:51:47Z</created_at>
        <updated_at type="datetime">2013-12-21T12:51:47Z</updated_at>
        <email>frederick@example.com</email>
        <data nil="true"/>
        <storage_state>cached</storage_state>
        <last_four_digits>1111</last_four_digits>
        <card_type>visa</card_type>
        <first_name>Bob</first_name>
        <last_name>Smith</last_name>
        <month type="integer">1</month>
        <year type="integer">2020</year>
        <address1>345 Main Street</address1>
        <address2>Apartment #7</address2>
        <city>Wanaque</city>
        <state>NJ</state>
        <zip>07465</zip>
        <country>United States</country>
        <phone_number>201-332-2122</phone_number>
        <full_name>Bob Smith</full_name>
        <payment_method_type>credit_card</payment_method_type>
        <errors>
        </errors>
        <verification_value>XXX</verification_value>
        <number>XXXX-XXXX-XXXX-1111</number>
      </payment_method>
    XML
  end

  let(:failed_payment_method_response) do
    xml = <<-XML
      <errors>
        <error key="errors.payment_method_not_found">Unable to find the specified payment method.</error>
      </errors>
    XML
  end

  let(:successful_purchase_response) do
    <<-XML
      <transaction>
        <amount type="integer">100</amount>
        <on_test_gateway type="boolean">true</on_test_gateway>
        <created_at type="datetime">2013-12-12T22:47:05Z</created_at>
        <updated_at type="datetime">2013-12-12T22:47:05Z</updated_at>
        <currency_code>USD</currency_code>
        <succeeded type="boolean">true</succeeded>
        <state>succeeded</state>
        <token>CtK2hq1rB9yvs0qYvQz4ZVUwdKh</token>
        <transaction_type>Purchase</transaction_type>
        <order_id nil="true"/>
        <ip nil="true"/>
        <description nil="true"/>
        <email nil="true"/>
        <merchant_name_descriptor nil="true"/>
        <merchant_location_descriptor nil="true"/>
        <gateway_specific_fields nil="true"/>
        <gateway_specific_response_fields nil="true"/>
        <gateway_transaction_id>59</gateway_transaction_id>
        <message key="messages.transaction_succeeded">Succeeded!</message>
        <gateway_token>7V55R2Y8oZvY1u797RRwMDakUzK</gateway_token>
        <response>
          <success type="boolean">true</success>
          <message>Successful purchase</message>
          <avs_code nil="true"/>
          <avs_message nil="true"/>
          <cvv_code nil="true"/>
          <cvv_message nil="true"/>
          <pending type="boolean">false</pending>
          <error_code></error_code>
          <error_detail nil="true"/>
          <cancelled type="boolean">false</cancelled>
          <created_at type="datetime">2013-12-12T22:47:05Z</created_at>
          <updated_at type="datetime">2013-12-12T22:47:05Z</updated_at>
        </response>
        <payment_method>
          <token>SvVVGEsjBXRDhhPJ7pMHCnbSQuT</token>
          <created_at type="datetime">2013-11-06T18:28:14Z</created_at>
          <updated_at type="datetime">2013-12-12T22:47:05Z</updated_at>
          <email nil="true"/>
          <data nil="true"/>
          <storage_state>retained</storage_state>
          <last_four_digits>1111</last_four_digits>
          <card_type>visa</card_type>
          <first_name>Gia</first_name>
          <last_name>Hammes</last_name>
          <month type="integer">4</month>
          <year type="integer">2020</year>
          <address1 nil="true"/>
          <address2 nil="true"/>
          <city nil="true"/>
          <state nil="true"/>
          <zip nil="true"/>
          <country nil="true"/>
          <phone_number nil="true"/>
          <full_name>Gia Hammes</full_name>
          <payment_method_type>credit_card</payment_method_type>
          <errors>
          </errors>
          <verification_value></verification_value>
          <number>XXXX-XXXX-XXXX-1111</number>
        </payment_method>
        <api_urls>
        </api_urls>
      </transaction>
    XML
  end

  let(:failed_purchase_response) do
    <<-XML
      <transaction>
        <amount type="integer">100</amount>
        <on_test_gateway type="boolean">false</on_test_gateway>
        <created_at type="datetime">2013-12-21T12:51:49Z</created_at>
        <updated_at type="datetime">2013-12-21T12:51:49Z</updated_at>
        <currency_code>USD</currency_code>
        <succeeded type="boolean">false</succeeded>
        <state>failed</state>
        <token>Hj5BPvWQJ0EPH6egV8hIztWMCOY</token>
        <transaction_type>Purchase</transaction_type>
        <order_id nil="true"/>
        <ip nil="true"/>
        <description nil="true"/>
        <email nil="true"/>
        <merchant_name_descriptor nil="true"/>
        <merchant_location_descriptor nil="true"/>
        <gateway_specific_fields nil="true"/>
        <gateway_specific_response_fields nil="true"/>
        <gateway_transaction_id nil="true"/>
        <message key="messages.payment_method_invalid">The payment method is invalid.</message>
        <gateway_token>GnWTB6GhqChi7VHGQSCgKDUZvNF</gateway_token>
        <payment_method>
          <token>Klrks0iaZLWbKQnDwiB4nBZYob5</token>
          <created_at type="datetime">2013-12-21T12:51:48Z</created_at>
          <updated_at type="datetime">2013-12-21T12:51:48Z</updated_at>
          <email nil="true"/>
          <data nil="true"/>
          <storage_state>cached</storage_state>
          <last_four_digits></last_four_digits>
          <card_type nil="true"/>
          <first_name></first_name>
          <last_name></last_name>
          <month nil="true"/>
          <year nil="true"/>
          <address1 nil="true"/>
          <address2 nil="true"/>
          <city nil="true"/>
          <state nil="true"/>
          <zip nil="true"/>
          <country nil="true"/>
          <phone_number nil="true"/>
          <full_name></full_name>
          <payment_method_type>credit_card</payment_method_type>
          <errors>
            <error attribute="first_name" key="errors.blank">First name can't be blank</error>
            <error attribute="last_name" key="errors.blank">Last name can't be blank</error>
            <error attribute="month" key="errors.invalid">Month is invalid</error>
            <error attribute="year" key="errors.expired">Year is expired</error>
            <error attribute="year" key="errors.invalid">Year is invalid</error>
            <error attribute="number" key="errors.blank">Number can't be blank</error>
          </errors>
          <verification_value></verification_value>
          <number></number>
        </payment_method>
        <api_urls>
        </api_urls>
      </transaction>
    XML
  end

  describe ".payment_method_to_hash" do
    it "should build payment_method as a hash" do
      payment_method = Spreedly::PaymentMethod.new_from(Nokogiri::XML(successful_payment_method_response))
      payment_method_as_hash = SpreedlyClient.payment_method_to_hash(payment_method)
      payment_method_as_hash[:token].should == 'CATQHnDh14HmaCrvktwNdngixMm'
    end
  end

  describe ".transaction_to_hash" do
    it "should build transaction as a hash" do
      transaction = Spreedly::Transaction.new_from(Nokogiri::XML(successful_purchase_response))
      transaction_as_hash = SpreedlyClient.transaction_to_hash(transaction, '501-c-3')
      transaction_as_hash[:token].should == 'CtK2hq1rB9yvs0qYvQz4ZVUwdKh'
      transaction_as_hash[:payment_method][:token].should == 'SvVVGEsjBXRDhhPJ7pMHCnbSQuT'
    end
  end

  describe ".retrieve_and_hash_payment_method" do
    it "should return payment_method as a hash with a classification key" do
      @spreedly.stub(:find_payment_method) { Spreedly::PaymentMethod.new_from(Nokogiri::XML(successful_payment_method_response)) }
      payment_method = SpreedlyClient.retrieve_and_hash_payment_method('501-c-3', 'CATQHnDh14HmaCrvktwNdngixMm')

      payment_method[:token].should == 'CATQHnDh14HmaCrvktwNdngixMm'
      payment_method[:data][:classification].should == '501-c-3'
    end

    it "should return a hash with an error code and message if unable to find payment method" do
      @spreedly.stub(:find_payment_method).and_raise Spreedly::XmlErrorsList.new(Nokogiri::XML(failed_payment_method_response))
      payment_method = SpreedlyClient.retrieve_and_hash_payment_method('501-c-3', 'nonexistent_payment_method_token')

      payment_method[:code] == 422
      payment_method[:errors][:message].should == "Unable to find the specified payment method."
    end
  end

  describe ".purchase_and_hash_response" do
    let(:payment_method) do
      {
        :token=>"CATQHnDh14HmaCrvktwNdngixMm",
        :created_at=>'2013-12-21 12:51:47 UTC',
        :updated_at=>'2013-12-21 12:51:47 UTC',
        :email=>"frederick@example.com",
        :storage_state=>"cached",
        :data=>{ :classification=>"501-c-3", :currency=>'USD' },
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
        :phone_number=>"201-332-2122"
      }
    end

    before :each do
      SpreedlyClient.stub(:create_environment) { nil }
    end

    it "should return purchase as a hash with the payment_method" do
      @spreedly.stub(:purchase_on_gateway) { Spreedly::Transaction.new_from(Nokogiri::XML(successful_purchase_response)) }
      purchase = SpreedlyClient.purchase_and_hash_response(payment_method)

      purchase[:token].should == 'CtK2hq1rB9yvs0qYvQz4ZVUwdKh'
      purchase[:payment_method][:token] == 'CATQHnDh14HmaCrvktwNdngixMm'
    end

    it "should return a hash with an error code, message, and payment method info on failure to purchase" do
      @spreedly.stub(:purchase_on_gateway).and_raise Spreedly::XmlErrorsList.new(Nokogiri::XML(failed_purchase_response))
      purchase = SpreedlyClient.purchase_and_hash_response(payment_method)

      purchase[:code].should == 422
      purchase[:errors][:message].should == "First name can't be blank"
      purchase[:payment_method][:email] == 'frederick@example.com'
    end
  end

  describe ".create_payment_method_and_purchase" do
    before :each do
      SpreedlyClient.stub(:create_environment) { nil }
    end

    it "should return payment method and not attempt to purchase if the payment method has errors" do
      @spreedly.stub(:find_payment_method).and_raise Spreedly::XmlErrorsList.new(Nokogiri::XML(failed_payment_method_response))
      payment_method = SpreedlyClient.retrieve_and_hash_payment_method('501-c-3', 'nonexistent_payment_method_token')

      SpreedlyClient.should_not_receive(:purchase_and_hash_response)
      result = SpreedlyClient.create_payment_method_and_purchase('501-c-3', 'nonexistent_payment_method_token')
      result.should == payment_method
    end

    it "should call purchase if the payment method has no errors" do
      @spreedly.stub(:find_payment_method) { Spreedly::PaymentMethod.new_from(Nokogiri::XML(successful_payment_method_response)) }
      SpreedlyClient.retrieve_and_hash_payment_method('501-c-3', 'CATQHnDh14HmaCrvktwNdngixMm')

      SpreedlyClient.should_receive(:purchase_and_hash_response)
      SpreedlyClient.create_payment_method_and_purchase('501-c-3', 'CATQHnDh14HmaCrvktwNdngixMm')
    end
  end
end
