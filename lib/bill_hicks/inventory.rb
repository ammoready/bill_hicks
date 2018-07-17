module BillHicks
  # Inventory item response structure:
  #
  #   {
  #     product:  "...",
  #     upc:      "...",
  #     quantity: "..."
  #   }
  class Inventory < Base

    CHUNK_SIZE = 2000
    INVENTORY_FILENAME = 'billhicksinventory.csv'

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def self.get_quantity_file(options = {})
      requires!(options, :username, :password)
      new(options).get_quantity_file
    end

    def self.quantity(options = {}, &block)
      requires!(options, :username, :password)
      new(options).all &block
    end

    def self.all(options = {}, &block)
      requires!(options, :username, :password)
      new(options).all &block
    end

    def all(&block)
      quantity_tempfile = get_file(INVENTORY_FILENAME)

      SmarterCSV.process(quantity_tempfile, {
        chunk_size: CHUNK_SIZE,
        force_utf8: true,
        convert_values_to_numeric: false,
        key_mapping: {
          product: :item_identifier,
          qty_avail: :quantity,
        }
      }) do |chunk|
        chunk.each do |item|
          yield item
        end
      end

      quantity_tempfile.close
      quantity_tempfile.unlink
      true
    end

    def get_quantity_file
      quantity_tempfile = get_file(INVENTORY_FILENAME)
      tempfile          = Tempfile.new

      SmarterCSV.process(quantity_tempfile, {
        chunk_size: CHUNK_SIZE,
        force_utf8: true,
        convert_values_to_numeric: false,
        key_mapping: {
          product: :item_identifier,
          qty_avail: :quantity,
        }
      }) do |chunk|
        chunk.each do |item|
          tempfile.puts("#{item[:item_identifier]},#{item[:quantity]}")
        end
      end

      quantity_tempfile.close
      quantity_tempfile.unlink
      tempfile.close
      tempfile.path
    end

    alias quantity all

  end
end
