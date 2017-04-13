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

    def self.process_as_chunks(size = 15, options = {}, &block)
      requires!(options, :username, :password)
      new(options).process_as_chunks(size, &block)
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

          row_hash[:brand] = BillHicks::BrandConverter.convert(row_hash[:product_name])

          catalog << row_hash
        end
      end

      catalog
    end

    # Streams csv and chunks it
    #
    # @size integer The number of items in each chunk
    def process_as_chunks(size, &block)
      connect(@options) do |ftp|
        temp_csv_file = Tempfile.new

        ftp.chdir(BillHicks.config.top_level_dir)
        ftp.getbinaryfile(CATALOG_FILENAME, temp_csv_file.path)

        SmarterCSV.process(temp_csv_file, { :chunk_size => size, :force_utf8 => true, :convert_values_to_numeric => false }) do |chunk|
          chunk.each do |item|
            item[:brand] = BillHicks::BrandConverter.convert(item[:product_name])
          end

          yield(chunk)
        end

        temp_csv_file.unlink
      end
    end

  end
end
