require 'bill_hicks/version'

require 'csv'
require 'net/ftp'

require 'bill_hicks/base'
require 'bill_hicks/catalog'

module BillHicks
  class NotAuthenticated < StandardError; end
end
