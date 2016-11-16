require 'bill_hicks/version'

require 'csv'
require 'net/ftp'

require 'bill_hicks/base'
require 'bill_hicks/catalog'
require 'bill_hicks/category'
require 'bill_hicks/inventory'
require 'bill_hicks/order'

module BillHicks
  class InvalidOrder < StandardError; end
  class NotAuthenticated < StandardError; end
end
