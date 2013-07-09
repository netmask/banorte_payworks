class BanorteTransaction
  attr_accessor :error_code, :message, :authnum, :order_id, :amount,
                :card_number, :cvv, :exp_date, :_original_post,
                :e, :time_in, :time_out, :card_type, :issuing_bank,
                :transaction_type, :transaction_status

  def self.from_post(post)
    #TODO this big huge method needs to be abstracted to an a class and we need to cas the proper primitive types
    parsed_post = CGI::parse(post)
    create_with_properties self do |transaction|
      transaction._original_post = post
      transaction.error_code = parsed_post['CcErrCode'][0]
      transaction.message = parsed_post['Text'][0]
      transaction.authnum = parsed_post['AuthCode'][0]
      transaction.order_id = parsed_post['OrderId'][0]
      transaction.amount = parsed_post['Total'][0]
      transaction.time_in = parsed_post['TimeIn'][0]
      transaction.time_out = parsed_post['TimeOut'][0]

      transaction.e = [parsed_post['E1'][0],
                    parsed_post['E2'][0],
                    parsed_post['E3'][0]]

      transaction.card_type = parsed_post['CardType'][0]
      transaction.issuing_bank = parsed_post['IssuingBank'][0]
      transaction.transaction_type = parsed_post['TransType'][0]
      transaction.transaction_status = parsed_post['TransStat'][0]

      transaction.card_number = parsed_post['Number'][0]
    end
  end

  def valid?
    error_code.eql? '1'
  end

  def validate!
    raise BpayworksException.new("Error::#{error_code}: #{message}") unless valid?
  end

  private
  def self.create_with_properties(clazz, &block)
    instance = clazz.new
    yield instance
    instance
  end

end
