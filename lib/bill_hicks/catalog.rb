module BillHicks
  # Catalog item response structure:
  #
  #   {
  #     product_name:      "...",
  #     upc:               "...",
  #     short_description: "...",
  #     long_description:  "...",
  #     category:          "...",
  #     price:             "...",
  #     weight:            "...",
  #     map:               "...",
  #     msrp:              "...",
  #   }
  class Catalog < Base

    CHUNK_SIZE = 500
    CATALOG_FILENAME = 'billhickscatalog.csv'.freeze
    PERMITTED_FEATURES = [
      'weight',
      'caliber',
      'action',
      'mount',
      'finish',
      'length',
      'diameter',
      'rail',
      'trigger',
      'barrel length',
      'silencer mount',
      'barrel',
      'stock',
      'internal bore',
      'thread pitch',
      'dimensions',
      'bulb type',
      'bezel diameter',
      'output max',
      'battery type',
      'mount type',
      'waterproof rating',
      'operating temperature'
    ]

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def self.all(options = {}, &block)
      requires!(options, :username, :password)
      new(options).all &block
    end

    def all(&block)
      connect(@options) do |ftp|
        tempfile = Tempfile.new

        ftp.chdir(BillHicks.config.top_level_dir)
        ftp.getbinaryfile(CATALOG_FILENAME, tempfile.path)

        SmarterCSV.process(tempfile, {
          chunk_size: CHUNK_SIZE,
          force_utf8: true,
          convert_values_to_numeric: false,
          key_mapping: {
            universal_product_code: :upc,
            product_name:           :name,
            product_weight:         :weight,
            product_price:          :price,
            category_description:   :category,
            marp:                   :map_price,
          }
        }) do |chunk|
          chunk.each do |item|
            item.except!(:category_code)

            item[:item_identifier] = item[:name]
            item[:brand]           = BillHicks::BrandConverter.convert(item[:name])
            item[:mfg_number]      = item[:name].split.last

            if item[:long_description].present?
              features = parse_features(item[:long_description])

              item[:action]  = features.delete(:action)  if features[:action].present?
              item[:caliber] = features.delete(:caliber) if features[:caliber].present?
              item[:weight]  = features.delete(:weight)  if features[:weight].present?

              item[:features] = features
            end

            yield item
          end
        end

        tempfile.unlink
      end
    end

    protected

    def parse_features(text)
      features = Hash.new
      text = text.split("-")

      text.each do |feature|
        if feature.include?(':') && feature.length <= 45
          key, value = feature.split(':')

          if key.nil? || value.nil?
            next
          end

          key, value = key.strip.downcase, value.strip

          if PERMITTED_FEATURES.include?(key)
            features[key.gsub(" ", "_")] = value
          end
        end
      end

      features
    end

  end
end
