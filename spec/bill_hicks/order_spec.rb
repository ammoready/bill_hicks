require 'spec_helper'

describe BillHicks::Order do

  let(:credentials) { { username: 'login', password: 'password' } }
  let(:default_header) do
    {
      customer:       '12345',
      purchase_order: '1000-300',
      ffl:            '12-aa-bb-1234',
      shipping: {
        name:      'Joe',
        address_1: '123 Cherry Lane',
        address_2: '',
        city:      'Sunnyville',
        state:     'SC',
        zip:       '12345'
      }
    }
  end

  before do
    ftp = instance_double('Net::FTP', :passive= => true, :debug_mode= => true)
    allow(ftp).to receive(:chdir).with('Test/toBHC') { true }
    allow(ftp).to receive(:puttextfile) { '' }
    allow(Net::FTP).to receive(:open).with('ftp.host.com', 'login', 'password') { |&block| block.call(ftp) }
    allow(ftp).to receive(:close)
  end

  describe '#add_header' do
    let(:order) { BillHicks::Order.new(credentials) }

    before do
      order.add_header(default_header)
    end

    it { expect(order.instance_variable_get(:@header)[:customer]).to eq('12345') }
    it { expect(order.instance_variable_get(:@header)[:purchase_order]).to eq('1000-300') }
    it { expect(order.instance_variable_get(:@header)[:shipping][:name]).to eq('Joe') }
    it { expect(order.instance_variable_get(:@header)[:shipping][:address_2]).to eq(nil) }
  end

  describe '#submit!' do
    let(:order) { BillHicks::Order.new(credentials) }

    before do
      order.add_header(default_header)
      order.add_item(item_number: 'ABCD', quantity: 1, price: '9.99')
    end

    it { expect(order.submit!).to eq(true) }
  end

end
