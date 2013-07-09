require 'httpclient'
require 'cgi'

module BanortePayworks

  PAYWORKS_URL = 'https://eps.banorte.com/recibo'
  PAYWORKS_3DS_URL = 'https://eps.banorte.com/secure3d/Solucion3DSecure.htm'

  MODE = {
    production: 'P',
    reject: 'R',
    accept: 'Y',
    random: 'R'
  }

  TYPE = {
    auth: 'Auth',
    pre_auth: 'PreAuth',
    post_auth: 'PostAuth',
    void: 'Void',
    credit: 'Credit',
    force_insert_auth: 'ForceInsertAuth',
    verify: 'Verify'
  }

  class SimpleTPV
    attr_accessor :config

    def initialize(config = {})
      self.config = config
    end

    def do_payment(order_id, card_number, exp_date, cvv, amount)
      do_transaction card_number: card_number,
                     exp_date: exp_date,
                     cvv: cvv,
                     amount: amount,
                     order_id: order_id,
                     response_path: 'http://sample.net/',
                     type: BanortePayworks::TYPE[:auth]
    end

    def void(transaction)
      do_transaction order_id: transaction.order_id,
                     amount: transaction.amount,
                     authnum: transaction.authnum,
                     card_number: transaction.card_number,
                     exp_date: transaction.exp_date,
                     cvv: transaction.cvv,
                     response_path: 'http://sample.net/',
                     type: BanortePayworks::TYPE[:void]

    end

    def do_transaction(properties = {})
      return_eval BanorteTransaction.from_post payworks_request(properties).first do |protocol|
        protocol.card_number = properties[:card_number]
        protocol.cvv = properties[:cvv]
        protocol.exp_date = properties[:exp_date]
        protocol.validate!
      end
    end

    protected

    def payworks_request(properties)
      HTTPClient.new.post(PAYWORKS_URL, {
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
      }).header['Location']
    end

    private

    def return_eval(object, &block)
      yield object
      object
    end
  end

end
