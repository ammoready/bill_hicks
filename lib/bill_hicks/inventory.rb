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
        temp_csv_file = Tempfile.new

        ftp.chdir(BillHicks.config.top_level_dir)
        ftp.getbinaryfile(INVENTORY_FILENAME, temp_csv_file.path)

        SmarterCSV.process(temp_csv_file, { :chunk_size => size, :force_utf8 => true, :convert_values_to_numeric => false, }) do |chunk|
          chunk.each do |item|
            item[:brand_name] = BillHicks::BrandConverter.convert(item[:product])
          end

          yield(chunk)
        end

        temp_csv_file.unlink
      end
    end

  end
end
