module BanortePayworks

  require 'httpclient'

  PAYWORKS_URL = "https://eps.banorte.com/recibo"
  PAYWORKS_3DS_URL = "https://eps.banorte.com/secure3d/Solucion3DSecure.htm"

  MODE = {
      :production => 'P',
      :reject => 'R',
      :accept => 'Y',
      :random => 'R'
  }

  TYPE = {
      :auth => 'Auth',
      :pre_auth => 'PreAuth',
      :post_auth => 'PostAuth',
      :void => 'Void',
      :credit => 'Credit',
      :force_insert_auth => 'ForceInsertAuth',
      :verify => 'Verify'
  }


  class BpayworksException < Exception
  end

  class BanorteTransaction
    require 'cgi'

    attr_accessor :error_code, :message, :authnum, :order_id, :amount, :card_number, :cvv, :exp_date


    def self.from_post(post)
      parsed_post = CGI::parse(post)
      protocol = BanorteTransaction.new
      protocol.error_code = parsed_post['CcErrCode'][0]
      protocol.message = parsed_post['Text'][0]
      protocol.authnum = parsed_post['AuthCode'][0]
      protocol.order_id = parsed_post['OrderId'][0]
      protocol.amount = parsed_post['Total'][0]
      protocol.card_number = parsed_post['Number'][0]
      protocol
    end


  end

  class SimpleTPV

    def initialize(config={})
      @config = config
    end

    #Simple call to payment
    def do_payment(order_id, card_number, exp_date, cvv, amount)
      do_transaction :card_number => card_number,
                     :exp_date => exp_date,
                     :cvv => cvv,
                     :amount => amount,
                     :order_id => order_id,
                     :response_path => 'http://sample.net/',
                     :type => BanortePayworks::TYPE[:auth]
    end

    def void(transaction)

      do_transaction :order_id => transaction.order_id,
                     :amount => transaction.amount,
                     :authnum => transaction.authnum,
                     :card_number => transaction.card_number,
                     :exp_date => transaction.exp_date,
                     :cvv => transaction.cvv,
                     :response_path => 'http://sample.net/',
                     :type => BanortePayworks::TYPE[:void]

    end

    def do_transaction(properties = {})

      location = HTTPClient.new.post(PAYWORKS_URL, {
          'Name' => @config[:username],
          'Password' => @config[:password],
          'ClientId' => @config[:client_id],
          'Mode' => @config[:mode],
          'TransType' => properties[:type],
          'Expires' => properties[:exp_date],
          'Number' => properties[:card_number],
          'Cvv2Indicator' => (properties[:cvv] == nil ? 0 : 1),
          'Cvv2Val' => properties[:cvv],
          'Total' => properties[:amount],
          'ResponsePath' => properties[:response_path],
          'OrderId' => properties[:order_id],
          'AuthCode' => properties[:authnum].to_s

      }).header['Location'].to_s

      puts location.inspect if properties[:verbose]

      protocol = BanorteTransaction.from_post location

      #hack ?
      protocol.card_number = properties[:card_number]
      protocol.cvv = properties[:cvv]
      protocol.exp_date = properties[:exp_date]

      if protocol.error_code != '1'
        raise BpayworksException.new("Error::#{protocol.error_code}: #{protocol.message}")
      else
        protocol
      end

    end

  end

end
