require 'spec_helper'

describe BillHicks::Catalog do

  it { expect(defined?(BillHicks::Catalog::CATALOG_FILENAME)).to eq('constant') }

  let(:ftp) { instance_double('Net::FTP', :passive= => true, :debug_mode= => true) }
  let(:credentials) { { username: 'login', password: 'password' } }

  before do
    allow(Net::FTP).to receive(:open).with('ftp.host.com', 'login', 'password') { |&block| block.call(ftp) }
  end

  describe '.all' do
    let(:billhickscatalog) { FixtureHelper.get_fixture_file('billhickscatalog.csv') }

    before do
      allow(ftp).to receive(:chdir).with('Test') { true }
      allow(ftp).to receive(:close) { nil }
      allow(ftp).to receive(:getbinaryfile) { nil }
      allow(Tempfile).to receive(:new).and_return(billhickscatalog)
      allow(billhickscatalog).to receive(:unlink) { nil }
    end

    it 'returns an array of all items' do
      expect(BillHicks::Catalog.all(credentials).count).to eq(67)
    end
  end

end
