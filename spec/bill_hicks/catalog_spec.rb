require 'spec_helper'

describe BillHicks::Catalog do

  it 'has CATALOG_FILENAME constant' do
    expect(defined?(BillHicks::Catalog::CATALOG_FILENAME)).to eq('constant')
  end

  it 'has PERMITTED_FEATURES constant' do
    expect(defined?(BillHicks::Catalog::PERMITTED_FEATURES)).to eq('constant')
  end

end
