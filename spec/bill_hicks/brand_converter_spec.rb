require 'spec_helper'

describe BillHicks::BrandConverter do

  describe '.convert' do
    it 'finds the corresponding brand for 2A' do
      expect(BillHicks::BrandConverter.convert('2A 1122')).to eq('2A Armament')
    end

    it 'finds the corresponding brand for GLOCK' do
      expect(BillHicks::BrandConverter.convert('GLOCK G43')).to eq('Glock')
    end

    it 'finds the corresponding brand for OAI' do
      expect(BillHicks::BrandConverter.convert('oai')).to eq('Olympic Arms')
    end
  end

end
