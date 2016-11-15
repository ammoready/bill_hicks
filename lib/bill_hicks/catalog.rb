module BillHicks
  class Catalog < Base

    # FIXME: Change this back to the normal filename as soon as they fix the headers in this file.
    # CATALOG_FILENAME = 'billhickscatalog.csv'
    CATALOG_FILENAME = 'billhickscatalog-fixed.csv'

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def self.all(options = {})
      requires!(options, :username, :password)
      new(options).all
    end

    # Field names:
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
    def all
      catalog = []

      connect(@options) do |ftp|
        ftp.chdir(FTP_DIR)

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

  end
end
