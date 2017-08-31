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

    def self.all(chunk_size = 15, options = {}, &block)
      requires!(options, :username, :password)
      new(options).all(chunk_size, &block)
    end

    def self.quantities(chunk_size = 15, options = {}, &block)
      requires!(options, :username, :password)
      new(options).quantities(chunk_size, &block)
    end

    def all(chunk_size, &block)
      connect(@options) do |ftp|
        begin
          csv_tempfile = Tempfile.new

          ftp.chdir(BillHicks.config.top_level_dir)
          ftp.getbinaryfile(INVENTORY_FILENAME, csv_tempfile.path)

          SmarterCSV.process(csv_tempfile, {
            :chunk_size => chunk_size,
            :force_utf8 => true,
            :convert_values_to_numeric => false,
            :key_mapping => {
              :qty_avail  => :quantity,
              :upc        => :item_identifier
            }
          }) do |chunk|
            chunk.each do |item|
              item.except!(:product)
            end

            yield(chunk)
          end
        ensure
          ftp.close
        end
      end
    end
  end
end
