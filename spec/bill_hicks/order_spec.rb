require 'spec_helper'

describe BillHicks::Order do

  let(:credentials) { { username: "login", password: "password" } }

  describe '#add_header' do
    let(:order) { BillHicks::Order.new(credentials) }

    before do
      order.add_header({
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
      })
    end

    it { expect(order.instance_variable_get(:@header)[:customer]).to eq('12345') }
    it { expect(order.instance_variable_get(:@header)[:purchase_order]).to eq('1000-300') }
    it { expect(order.instance_variable_get(:@header)[:shipping][:name]).to eq('Joe') }
    it { expect(order.instance_variable_get(:@header)[:shipping][:address_2]).to eq(nil) }
  end

end
