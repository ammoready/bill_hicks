require 'spec_helper'

describe BillHicks::ResponseFile do

  let(:credentials) { { username: 'login', password: 'password' } }

  describe '.all' do
    let(:ftp) { instance_double('Net::FTP') }

    before do
      allow(ftp).to receive(:nlst).with('*.txt') { ['file1.txt', 'file2.txt'] }
    end

    it { expect(BillHicks::ResponseFile.all(ftp).length).to eq(2) }
  end

  describe '#ack?' do
    let(:ftp) { instance_double('Net::FTP') }

    context "is an ACK file" do
      let(:response_file) { BillHicks::ResponseFile.new(ftp, credentials.merge(filename: 'ACK.20161117-0001.txt')) }

      it { expect(response_file.ack?).to be(true) }
    end

    context "is NOT an ACK file" do
      let(:response_file) { BillHicks::ResponseFile.new(ftp, credentials.merge(filename: 'ASN.20161117-0001.txt')) }

      it { expect(response_file.ack?).to be(false) }
    end
  end

  describe '#asn?' do
    let(:ftp) { instance_double('Net::FTP') }

    context "is an ASN file" do
      let(:response_file) { BillHicks::ResponseFile.new(ftp, credentials.merge(filename: 'ASN.20161117-0001.txt')) }

      it { expect(response_file.asn?).to be(true) }
    end

    context "is NOT an ASN file" do
      let(:response_file) { BillHicks::ResponseFile.new(ftp, credentials.merge(filename: 'ACK.20161117-0001.txt')) }

      it { expect(response_file.asn?).to be(false) }
    end
  end

  describe '#content' do
    let(:ftp) { instance_double('Net::FTP') }
    let(:filename) { 'ACK-20161117-0001.txt' }
    let(:response_file) { BillHicks::ResponseFile.new(ftp, credentials.merge(filename: filename)) }

    before do
      allow(ftp).to receive(:gettextfile).with(filename, nil) { FixtureHelper.get_fixture_file('sample_ack_file.txt').read }
      response_file.content
    end

    it { expect(response_file.instance_variable_get(:@content).length).to be > 0 }
  end

  describe '#to_json' do
    context 'all is fine' do
      let(:ftp) { instance_double('Net::FTP') }
      let(:filename) { 'ACK-20161117-0001.txt' }
      let(:response_file) { BillHicks::ResponseFile.new(ftp, credentials.merge(filename: filename)) }

      before do
        allow(response_file).to receive(:content) { FixtureHelper.get_fixture_file('sample_ack_file.txt').read }
        @json = response_file.to_json
      end

      it { expect(@json["999999910"][0]).to have_key("PO Date") }
      it { expect(@json["999999910"][0]).to have_key("PO Number") }
      it { expect(@json["999999910"][0]).to have_key("Quantity Ordered") }
      it { expect(@json["999999910"][0]).to have_key("Quantity Committed") }
      it { expect(@json["999999910"][0]).to have_key("UPC Number") }
      it { expect(@json["999999910"][0]).to have_key("BHC Order Number") }
    end

    context 'bad ASN file' do
      let(:ftp) { instance_double('Net::FTP') }
      let(:filename) { '20161117-0001.txt' }
      let(:response_file) { BillHicks::ResponseFile.new(ftp, credentials.merge(filename: filename)) }

      before do
        allow(response_file).to receive(:content) { FixtureHelper.get_fixture_file('sample_bad_asn_file.txt').read }
        @json = response_file.to_json
      end

      it { expect(@json["999999910"][0]).to have_key("PO Date") }
      it { expect(@json["999999910"][0]).to have_key("UPC Number") }
      it { expect(@json["999999910"][0]).to have_key("Tracking Number") }
      it { expect(@json["999999910"][0]).to have_key("Carrier") }
      it { expect(@json["999999910"][0]).to have_key("BHC Order Number") }
    end
  end

end
