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

    # Returns an array of hashes with the inventory item details.
    def all
      inventory = []

      connect(@options) do |ftp|
        ftp.chdir(BillHicks.config.top_level_dir)

        lines = ftp.gettextfile(INVENTORY_FILENAME, nil)

        CSV.parse(lines, headers: :first_row) do |row|
          inventory << {
            product: row.fetch('Product'),
            upc: row.fetch('UPC'),
            quantity: (Integer(row.fetch('Qty Avail')) rescue 0)
          }
        end
      end

      inventory
    end

  end
end
