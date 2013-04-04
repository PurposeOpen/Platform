require "spec_helper"

EXPECTED_ANTI_FRAUD_REQUEST=<<ANTIFRAUD
<?xml version="1.0" encoding="UTF-8"?> <SecurePayMessage>
<MessageInfo>
  <messageID>uuid</messageID>
  <messageTimestamp/>
  <timeoutValue>60</timeoutValue>
  <apiVersion>xml-4.2</apiVersion>
</MessageInfo>
<MerchantInfo>
  <merchantID>ABC0001</merchantID>
  <password>changeit</password>
</MerchantInfo>
<RequestType>Payment</RequestType>
<Payment>
  <TxnList count="1"><Txn ID="1">
  <txnType>0</txnType>
  <txnSource>23</txnSource>
  <amount>100</amount>
  <currency>AUD</currency>
  <purchaseOrderNo>37</purchaseOrderNo>
  <CreditCardInfo>
    <cardNumber>4111111111111111</cardNumber>
    <expiryDate>05/13</expiryDate>
    <cvv>123</cvv>
  </CreditCardInfo>
  <BuyerInfo>
    <firstName>Leonardo</firstName>
    <lastName>Borges</lastName>
    <zipCode>2000</zipCode>
    <town>Sydney</town>
    <billingCountry>AU</billingCountry>
    <deliveryCountry>AU</deliveryCountry>
    <emailAddress>my@email.com</emailAddress>
    <ip>200.30.12.1</ip>
  </BuyerInfo>
</Txn>
</TxnList> </Payment>
</SecurePayMessage>
ANTIFRAUD

MOCK_RESPONSE=<<RESPONSE
<?xml version="1.0" encoding="UTF-8"?> <SecurePayMessage>
<MessageInfo>
  <messageID>8af793f9af34bea0cf40f5fb5c630c</messageID>
  <messageTimestamp>20152303111359163000+660</messageTimestamp>
  <apiVersion>xml-4.2</apiVersion>
</MessageInfo>
<MerchantInfo>
  <merchantID>ABC0001</merchantID>
</MerchantInfo>
<RequestType>Payment</RequestType>
<Status>
  <statusCode>000</statusCode>
  <statusDescription>Normal</statusDescription>
</Status>
<Payment>
  <TxnList count="1"><Txn ID="1">
  <txnType>21</txnType>
  <txnSource>0</txnSource>
  <amount>100</amount>
  <currency>AUD</currency>
  <purchaseOrderNo>test</purchaseOrderNo>
  <approved>Yes</approved>
  <responseCode>00</responseCode>
  <responseText>Approved</responseText>
  <settlementDate>20040318</settlementDate>
  <txnID>009844</txnID>
  <CreditCardInfo>
    <pan>444433...111</pan>
    <expiryDate>09/15</expiryDate>
    <cardType>6</cardType>
    <cardDescription>Visa</cardDescription>
  </CreditCardInfo>
  <antiFraudResponseCode>000</antiFraudResponseCode>
  <antiFraudResponseText>Antifraud check passed</antiFraudResponseText>
  <FraudGuard>
    <score>85</score>
    <infoIpCountry>AUD</infoIpCountry>
    <infoCardCountry>NZL</infoCardCountry>
    <ipCountryFail>yes</ipCountryFail>
    <minAmountFail>yes</minAmountFail>
    <maxAmountFail>yes</maxAmountFail>
    <openProxyFail>5</openProxyFail>
    <IpCountryCardCountryFail>5</IpCountryCardCountryFail>
    <ipCardFail>5</ipCardFail>
    <ipRiskCountryFail>5</ipRiskCountryFail>
    <ipBillingFail>5</ipBillingFail>
    <ipDeliveryFail>5</ipDeliveryFail>
    <billingDeliveryFail>5</billingDeliveryFail>
    <freeEmailFail>5</freeEmailFail>
    <tooManySameBank>5</tooManySameBank>
    <tooManyDeclined>5</tooManyDeclined>
    <tooManySameIp>5</tooManySameIp>
    <tooManySameCard>5</tooManySameCard>
    <lowHighAmount>5</lowHighAmount>
    <tooManySameEmail>5</tooManySameEmail>
  </FraudGuard>
  <ThirdPartyResponse>
    <returnCode>0</returnCode>
    <result1>1</result1>
    <result2>1</result2>
    <additionalInfo1/>
    <additionalInfo2/>
    <PSPResult>1</PSPResult>
    <PSPScore>100</PSPScore>
    <MerchantResult>1</MerchantResult>
    <MerchantScore>100</MerchantScore>
    <ProxyIp/>
    <FreeE-MailDomain/>
    <IPCountry>AUS</IPCountry>
    <BINCountry>NZL</BINCountry>
    <Geo-RegionMatch>1</Geo-RegionMatch>
    <Geo-CountryMatch>1</Geo-CountryMatch>
  </ThirdPartyResponse>
</Txn>
</TxnList> </Payment>
    </SecurePayMessage>
RESPONSE

describe ActiveMerchant::Billing::SecurePayAuGateway do
  describe "Anti-Fraud Payment" do
    it "should build the correct request XML for anti-fraud one-off payments" do
      gateway = ActiveMerchant::Billing::SecurePayAuGateway.new(:login => "ABC0001", :password => "changeit", :test => true)
      card ||= ActiveMerchant::Billing::CreditCard.new(
          :type => "VISA",
          :first_name => "James",
          :last_name => "Hetfield",
          :number => "4111111111111111",
          :month => "05",
          :year => "2013",
          :verification_value => "123"
      )

      options = {
          :order_id => 37,
          :first_name => "Leonardo",
          :last_name => "Borges",
          :zip_code => "2000",
          :town => "Sydney",
          :billing_country => "AU",
          :email => "my@email.com",
          :ip => "200.30.12.1",
      }

      gateway.stub(:generate_timestamp).with { "timestamp" }
      ActiveMerchant::Utils.stub(:generate_unique_id) { "uuid" }

      gateway.should_receive(:ssl_post)
        .with(ActiveMerchant::Billing::SecurePayAuGateway::TEST_ANTI_FRAUD_URL, EXPECTED_ANTI_FRAUD_REQUEST.gsub(/>\s+</,'><').gsub("\n", ''))
        .and_return(MOCK_RESPONSE.gsub(/>\s+</,'><').gsub("\n", ''))

      #this makes sure the logging obfuscates the credit card information
      logger = double
      Rails.stub(:logger) {logger}
      logger.should_receive(:info).with(/cardNumber>4XXXXXXXXXXX1111<.+cvv>XXX</)
      logger.should_receive(:info)
      
      gateway.purchase_with_anti_fraud(100, card, options)
    end

  end
end