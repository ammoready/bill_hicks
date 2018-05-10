module BillHicks
  # Inventory item response structure:
  #
  #   {
  #     product:  "...",
  #     upc:      "...",
  #     quantity: "..."
  #   }
  class Inventory < Base

    INVENTORY_FILENAME = 'billhicksinventory.csv'

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def self.get_quantity_file(options = {})
      requires!(options, :username, :password)
      new(options).get_quantity_file
    end

    def self.quantity(chunk_size = 15, options = {}, &block)
      requires!(options, :username, :password)
      new(options).all(chunk_size, &block)
    end

    def self.all(chunk_size = 15, options = {}, &block)
      requires!(options, :username, :password)
      new(options).all(chunk_size, &block)
    end

    def all(chunk_size, &block)
      quantity_tempfile = get_file(INVENTORY_FILENAME)

      SmarterCSV.process(quantity_tempfile.open, {
        chunk_size: chunk_size,
        force_utf8: true,
        convert_values_to_numeric: false,
        key_mapping: {
          product: :item_identifier,
          qty_avail: :quantity,
        }
      }) do |chunk|
        chunk.each do |item|
          item.except!(:product)
        end

        yield(chunk)
      end

      quantity_tempfile.unlink
    end

    def get_quantity_file
      quantity_tempfile = get_file(INVENTORY_FILENAME)
      tempfile          = Tempfile.new

      SmarterCSV.process(quantity_tempfile.open, {
        chunk_size: 100,
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

      quantity_tempfile.unlink
      tempfile.close

      tempfile.path
    end

    alias quantity all

  end
end
