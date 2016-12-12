require "spec_helper"

describe BillHicks do
  it "has a version number" do
    expect(BillHicks::VERSION).not_to be nil
  end

  describe "::Configuration" do
    before do
      BillHicks.configure do |config|
        config.ftp_host       = "ftp.host.com"
        config.top_level_dir  = "Test"
        config.submission_dir = "toBHC"
        config.response_dir   = "fromBHC"
      end
    end

    it { expect(BillHicks.config.ftp_host).to eq("ftp.host.com") }
    it { expect(BillHicks.config.top_level_dir).to eq("Test") }
    it { expect(BillHicks.config.submission_dir).to eq("toBHC") }
    it { expect(BillHicks.config.response_dir).to eq("fromBHC") }

    describe '#full_submission_dir' do
      it { expect(BillHicks.config.full_submission_dir).to eq("Test/toBHC") }
    end

    describe '#full_response_dir' do
      it { expect(BillHicks.config.full_response_dir).to eq("Test/fromBHC") }
    end
  end
end
