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

    def self.all(options = {})
      requires!(options, :username, :password)
      new(options).all
    end

    def self.process_as_chunks(size = 15, options = {}, &block)
      requires!(options, :username, :password)
      new(options).process_as_chunks(size, &block)
    end

    # Returns an array of hashes with the inventory item details.
    def all
      inventory = []

      connect(@options) do |ftp|
        ftp.chdir(BillHicks.config.top_level_dir)

        lines = ftp.gettextfile(INVENTORY_FILENAME, nil)

        CSV.parse(lines, headers: :first_row) do |row|
          inventory << {
            brand_name: BillHicks::BrandConverter.convert(row.fetch('Product')),
            product: row.fetch('Product'),
            upc: row.fetch('UPC'),
            quantity: (Integer(row.fetch('Qty Avail')) rescue 0)
          }
        end
      end

      inventory
    end

    # Streams csv and chunks it
    #
    # @size integer The number of items in each chunk
    def process_as_chunks(size, &block)
      connect(@options) do |ftp|
        tempfile = Tempfile.new

        ftp.chdir(BillHicks.config.top_level_dir)
        ftp.getbinaryfile(INVENTORY_FILENAME, tempfile.path)

        smart_options = {
          chunk_size: size,
          key_mapping: { qty_avail: :quantity },
          force_utf8: true,
          convert_values_to_numeric: false
        }

        SmarterCSV.process(tempfile, smart_options) do |chunk|
          yield(chunk)
        end

        tempfile.unlink
      end
    end

  end
end
