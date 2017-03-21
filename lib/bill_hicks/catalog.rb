module BillHicks
  # Catalog item response structure:
  #
  #   {
  #     product_name:           "...",
  #     universal_product_code: "...",
  #     short_description:      "...",
  #     long_description:       "...",
  #     category_code:          "...",
  #     category_description:   "...",
  #     product_price:          "...",
  #     small_image_path:       "...",
  #     large_image_path:       "...",
  #     product_weight:         "...",
  #     marp:                   "...",
  #     msrp:                   "...",
  #     upc:                    "..."  # alias of ':universal_product_code'
  #   }
  class Catalog < Base

    CATALOG_FILENAME = 'billhickscatalog.csv'

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def self.all(options = {})
      requires!(options, :username, :password)
      new(options).all
    end

    def self.process_as_chunks(size = 15, options = {})
      requires!(options, :username, :password)
      new(options).process_as_chunks(size) do |chunk|
        yield(chunk)
      end
    end

    # Returns an array of hashes with the catalog item details.
    def all
      catalog = []

      connect(@options) do |ftp|
        ftp.chdir(BillHicks.config.top_level_dir)

        lines = ftp.gettextfile(CATALOG_FILENAME, nil)

        CSV.parse(lines, headers: :first_row) do |row|
          row_hash = {}

          # Turn the row into a hash with header names as symbolized keys.
          row.each { |r| row_hash[r.first.to_sym] = r.last }

          # Alias the ':universal_product_code' as ':upc'.
          row_hash[:upc] = row_hash[:universal_product_code]

          catalog << row_hash
        end
      end

      catalog
    end

    # Streams csv and chunks it
    #
    # @size integer The number of items in each chunk
    def process_as_chunks(size)
      connect(@options) do |ftp|
        ftp.chdir(BillHicks.config.top_level_dir)

        csv_data = StringIO.new(ftp.gettextfile(CATALOG_FILENAME, nil))

        SmarterCSV.process(csv_data, { :chunk_size => size }) do |chunk|
          yield(chunk)
        end
      end
    end

  end
end
