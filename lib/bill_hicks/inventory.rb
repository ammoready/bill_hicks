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

    def self.quantity(chunk_size = 15, options = {}, &block)
      requires!(options, :username, :password)
      new(options).all(chunk_size, &block)
    end

    def self.all(chunk_size = 15, options = {}, &block)
      requires!(options, :username, :password)
      new(options).all(chunk_size, &block)
    end

    def all(chunk_size, &block)
      connect(@options) do |ftp|
        begin
          tempfile = Tempfile.new

          ftp.chdir(BillHicks.config.top_level_dir)
          ftp.getbinaryfile(INVENTORY_FILENAME, tempfile.path)

          SmarterCSV.process(tempfile, {
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
        ensure
          tempfile.unlink
          ftp.close
        end
      end
    end

    alias quantity all

  end
end
