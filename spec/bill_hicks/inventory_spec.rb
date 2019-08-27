require 'spec_helper'

describe BillHicks::Inventory do

  it { expect(defined?(BillHicks::Inventory::INVENTORY_FILENAME)).to eq('constant') }

  let(:ftp) { instance_double('Net::FTP', :passive= => true, :debug_mode= => true) }
  let(:credentials) { { username: 'login', password: 'password' } }

  before do
    allow(Net::FTP).to receive(:open).with('ftp.host.com', 'login', 'password') { |&block| block.call(ftp) }
  end

  describe '.all' do
    let(:billhicksinventory) { FixtureHelper.get_fixture_file('billhicksinventory.csv') }

    before do
      allow(ftp).to receive(:chdir).with('Test') { true }
      allow(ftp).to receive(:close) { nil }
      allow(ftp).to receive(:getbinaryfile) { nil }
      allow(Tempfile).to receive(:new).and_return(billhicksinventory)
      allow(billhicksinventory).to receive(:unlink) { nil }
    end

    it 'returns an array of items' do
      items = BillHicks::Inventory.all(credentials)

      expect(items.count).to eq(60)
    end
  end

end
