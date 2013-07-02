require 'banorte_payworks'

describe BanortePayworks::SimpleTPV do
  it "Call do transaction" do
    tpv = BanortePayworks::SimpleTPV.new :username => 'tienda19',
                                         :password => '2006',
                                         :client_id=>'19',
                                         :mode=>BanortePayworks::MODE[:accept]

    transaction = tpv.do_payment(rand(100000),4916098986962263,'12/13','123',1.0)
    tpv.void transaction

  end
end
