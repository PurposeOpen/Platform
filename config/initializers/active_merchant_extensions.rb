require 'secure_pay_anti_fraud_support'

ActiveMerchant::Billing::Gateway.default_currency = "AUD"

module ActiveMerchant
  module Billing
    class SecurePayAuGateway < Gateway
      include SecurePayAntiFraudSupport
      def add_trigger(amount, creditcard, options = {})
        periodic_request(build_trigger_request(amount, creditcard, options.merge!(:action_type => "add")))
      end

      def periodic_request(request)
        periodic_test_url = "https://test.securepay.com.au/xmlapi/periodic"
        periodic_url      = "https://api.securepay.com.au/xmlapi/periodic"
        parse_response(parse(ssl_post(test? ? periodic_test_url : periodic_url, request)))
      end
      
      def refund_request(request)
        parse_response(parse(ssl_post(test? ? TEST_URL : LIVE_URL, request)))
      end
      
      def parse_response(response)
        Response.new(success?(response), message_from(response), response, 
          :test => test?, 
          :authorization => authorization_from(response)
        )
      end
      
      def refund(amount, options = {})
        commit :credit, build_refund_request(amount, options)
      end

      def trigger(amount, options={})
        periodic_request(build_trigger_request(amount, nil, options.merge!(:action_type => "trigger")))
      end

      def delete(options={})
        periodic_request(build_trigger_request(nil, nil, options.merge!(:action_type => "delete")))
      end
      
      def build_refund_request(amount, options={})
        xml = Builder::XmlMarkup.new
        xml.tag! 'amount', amount
        xml.tag! 'txnID', options[:txn_id]
        xml.tag! 'purchaseOrderNo', options[:order_id].to_s.gsub(/[ ']/, '')
        xml.target!
      end
      
      def build_trigger_request(amount, credit_card=nil,options={})
        xml = Builder::XmlMarkup.new
        xml.instruct!
        xml.tag! 'SecurePayMessage' do
          xml.tag! 'MessageInfo' do
            xml.tag! 'messageID', Utils.generate_unique_id.slice(0, 30)
            xml.tag! 'messageTimestamp', generate_timestamp
            xml.tag! 'timeoutValue', request_timeout
            xml.tag! 'apiVersion', API_VERSION
          end

          xml.tag! 'MerchantInfo' do
            xml.tag! 'merchantID', @options[:login]
            xml.tag! 'password', @options[:password]
          end

          xml.tag! 'RequestType', 'Periodic'
          xml.tag! 'Periodic' do
            xml.tag! 'PeriodicList', "count" => 1 do
              xml.tag! 'PeriodicItem', "ID" => 1 do
                xml.tag! 'actionType', options[:action_type]
                xml.tag! 'purchaseOrderNo', options[:order_id]
                xml.tag! 'clientID', options[:client_id]
                if credit_card
                  xml.tag! 'CreditCardInfo' do
                    xml.tag! 'cardNumber', credit_card.number
                    xml.tag! 'expiryDate', expdate(credit_card)
                  end
                end
                if amount
                  xml.tag! 'amount', amount
                end
                xml.tag! 'periodicType', '4' # Triggered-payment
              end
            end
          end
        end
        xml.target!
      end
    end
    
    class BogusGateway < Gateway     
      MAGIC_CENTS_TO_FORCE_FAILURE = 123 
      def add_trigger(amount, creditcard, options = {})
        @creditcard = creditcard # Store for later triggering        
      end
      
      def trigger(amount, options = {})
        @creditcard ||= ActiveMerchant::Billing::CreditCard.new(
          :type => "visa",
          :first_name => "Recurring payments do", 
          :last_name => "not need a card in prod", 
          :number => "1", 
          :month => "12", 
          :year => "2099",
          :verification_value => "123"
        )
        purchase(amount, @creditcard, options)
      end

      def purchase(money, creditcard, options = {})
        money = amount(money)
        case creditcard.number
          when '1','4111111111111111','41111'
            Response.new(true, SUCCESS_MESSAGE, {:paid_amount => money}, :test => true)
          when '2'
            Response.new(false, FAILURE_MESSAGE, {:paid_amount => money, :error => FAILURE_MESSAGE },:test => true)
          else
            raise Error, ERROR_MESSAGE
        end
      end
      
      def build_request(action_type, request)
        request
      end
      
      def build_refund_request(amount, options={})
        {:amount => amount}
      end

      def delete(trigger_id)
        @creditcard = nil
      end

      def refund_request(request)
        success = request[:amount] != MAGIC_CENTS_TO_FORCE_FAILURE
        Response.new(success, "Bogus Gateway: #{success ? 'Approved' : 'Failed'} Refund", {:amount => request[:amount], :txn_type => "4"}, :test => true)
      end

      def purchase_with_anti_fraud(money, credit_card, options = {})
        purchase(money, credit_card, options)
      end
    end
  end
end