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

    def self.all(chunk_size = 15, options = {}, &block)
      requires!(options, :username, :password)
      new(options).all(chunk_size, &block)
    end

    def all(chunk_size, &block)
      connect(@options) do |ftp|
        csv_tempfile = Tempfile.new

        ftp.chdir(BillHicks.config.top_level_dir)
        ftp.getbinaryfile(CATALOG_FILENAME, csv_tempfile.path)

        SmarterCSV.process(csv_tempfile, {
          :chunk_size => chunk_size,
          :force_utf8 => true,
          :convert_values_to_numeric => false,
          :key_mapping => {
            :universal_product_code => :upc,
            :product_name           => :name,
            :product_weight         => :weight,
            :product_price          => :price,
            :category_description   => :category
          }
        }) do |chunk|
          chunk.each do |item|
            item.except!(:category_code)

            item[:item_identifier] = item[:upc]
            item[:brand] = BillHicks::BrandConverter.convert(item[:name])
          end

          yield(chunk)
        end
      end
    end

  end
end
