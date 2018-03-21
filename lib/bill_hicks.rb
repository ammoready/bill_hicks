require 'bill_hicks/version'

require 'csv'
require 'net/ftp'
require 'smarter_csv'
require 'tempfile'

require 'bill_hicks/base'
require 'bill_hicks/ftp'
require 'bill_hicks/catalog'
require 'bill_hicks/category'
require 'bill_hicks/inventory'
require 'bill_hicks/order'
require 'bill_hicks/response_file'
require 'bill_hicks/user'
require 'bill_hicks/brand_converter'

module BillHicks
  class InvalidOrder < StandardError; end
  class NotAuthenticated < StandardError; end
  
  class << self
    attr_accessor :config
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.configure
    yield(config)
  end

  class Configuration
    attr_accessor :debug_mode
    attr_accessor :ftp_host
    attr_accessor :response_dir
    attr_accessor :submission_dir
    attr_accessor :top_level_dir

    def initialize
      @debug_mode     ||= false
      @ftp_host       ||= "billhicksco.hostedftp.com"
      @top_level_dir  ||= "AmmoReady"
      @submission_dir ||= "toBHC"
      @response_dir   ||= "fromBHC"
    end

    def full_submission_dir
      File.join(@top_level_dir, @submission_dir)
    end

    def full_response_dir
      File.join(@top_level_dir, @response_dir)
    end
  end
end
