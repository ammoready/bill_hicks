require 'bill_hicks/version'

require 'csv'
require 'net/ftp'

require 'bill_hicks/base'
require 'bill_hicks/catalog'
require 'bill_hicks/inventory'

module BillHicks
  class NotAuthenticated < StandardError; end
end
