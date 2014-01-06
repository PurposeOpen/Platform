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
end
