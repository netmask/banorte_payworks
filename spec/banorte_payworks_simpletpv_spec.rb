require 'banorte_payworks'

describe BanortePayworks::SimpleTPV do
  describe '#transaction' do
    let(:credit_card_number){ 4916098986962263 }
    let(:expiration_date){ '12/24' }
    let(:cvv){ 123 }
    let(:amount){ 1.0 }
    let(:order_id){ rand(10000) }

    let(:tpv) do
      BanortePayworks::SimpleTPV.new :username => 'tienda19',
                                     :password => '2006',
                                     :client_id=>'19',
                                     :mode=>BanortePayworks::MODE[:accept]
    end

    let(:result){tpv.do_payment(rand(100000), credit_card_number, expiration_date, '123', 1.0)}

    it{ expect(result.valid?).to be_truthy }
    it{ expect(result.card_number).to_not be_nil }
    it{ expect(tpv.void(result).valid?).to be_truthy }
  end
end
