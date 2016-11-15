module BillHicks
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

    # Field names:
    #
    #   {
    #     product:  "...",
    #     upc:      "...",
    #     quantity: "..."
    #   }
    def all
      inventory = []

      connect(@options) do |ftp|
        ftp.chdir(FTP_DIR)

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
