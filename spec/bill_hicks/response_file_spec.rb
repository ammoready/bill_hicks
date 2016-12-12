require 'spec_helper'

describe BillHicks::ResponseFile do

  let(:credentials) { { username: "login", password: "password" } }

  describe '.all' do
    let(:all) { BillHicks::ResponseFile.all(credentials) }

    before do
      ftp = instance_double("Net::FTP", :passive= => true)
      allow(ftp).to receive(:chdir).with("Test/fromBHC") { true }
      allow(ftp).to receive(:nlst).with("*.txt") { ["file1.txt", "file2.txt"] }
      allow(Net::FTP).to receive(:open).with("ftp.host.com", "login", "password") { |&block| block.call(ftp) }
    end

    it { expect(all.length).to eq(2) }
  end

  describe '#content' do
    let(:filename) { '20161117-0001.txt' }
    let(:response_file) { BillHicks::ResponseFile.new(credentials.merge(filename: filename)) }

    before do
      ftp = instance_double("Net::FTP", :passive= => true)
      allow(ftp).to receive(:chdir).with("Test/fromBHC") { true }
      allow(ftp).to receive(:gettextfile).with(filename, nil) { sample_ack_file }
      allow(Net::FTP).to receive(:open).with("ftp.host.com", "login", "password") { |&block| block.call(ftp) }
      response_file.content
    end

    it { expect(response_file.instance_variable_get(:@content).length).to be > 0 }
  end

  describe '#to_json' do
    let(:filename) { '20161117-0001.txt' }
    let(:response_file) { BillHicks::ResponseFile.new(credentials.merge(filename: filename)) }

    before do
      allow(response_file).to receive(:content) { sample_ack_file }
      @json = response_file.to_json
    end

    it { expect(@json["999999910"][0]).to have_key("PO Date") }
    it { expect(@json["999999910"][0]).to have_key("PO Number") }
    it { expect(@json["999999910"][0]).to have_key("Quantity Ordered") }
    it { expect(@json["999999910"][0]).to have_key("Quantity Committed") }
    it { expect(@json["999999910"][0]).to have_key("UPC Number") }
  end

end
