module BillHicks
  # To submit an order:
  #
  # * Instantiate a new Order, passing in `:username` and `:password`
  # * Call {#add_header}
  # * Call {#add_item} for each item on the order
  # * Call {#submit!} to send the order
  #
  # See each method for a list of required options.
  class Order < Base

    ORDER_UPLOAD_DIR = [FTP_DIR, 'toBHC'].join('/')

    # @option options [String] :username *required*
    # @option options [String] :password *required*
    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
      @items = []
    end

    # @param [Hash] header
    #   * :customer [String] *required*
    #   * :purchase_order [String] *required*
    #   * :ffl [String] *required*
    #   * :shipping [Hash] *required*
    #     * :name [String] *required*
    #     * :address_1 [String] *required*
    #     * :address_2 [String] optional
    #     * :city [String] *required*
    #     * :state [String] *required*
    #     * :zip [String] *required*
    def add_header(header = {})
      requires!(header, :customer, :purchase_order, :ffl, :shipping)
      requires!(header[:shipping], :name, :address_1, :city, :state, :zip)
      @header = header
    end

    # @option item [String] :item_number *required*
    # @option item [Integer] :quantity *required*
    # @option item [String] :price *required* - Decimal formatted price, without currency sign
    # @option item [String] :description optional
    def add_item(item = {})
      requires!(item, :item_number, :quantity, :price)
      @items << item
    end

    def submit!
      raise BillHicks::InvalidOrder.new("Must call #add_header before submitting") if @header.nil?
      raise BillHicks::InvalidOrder.new("Must add items with #add_item before submitting") if @items.empty?

      @order_filename = "#{@header[:purchase_order]}-order.txt"
      @order_file = Tempfile.new(@order_filename)
      begin
        CSV.open(@order_file.path, 'w+') do |csv|
          csv << header_names
          csv << header_fields
          csv << items_header
          @items.each do |item|
            csv << item_fields(item)
          end
        end

        upload!
      ensure
        # Close and delete (unlink) file.
        @order_file.close
        @order_file.unlink
      end

      # TODO: Find some way of returning a meaningful true/false. Currently, if there's a problem, an exception is raised.
      true
    end

    private

    def header_names
      ['HL', 'Customer#', 'Ship to Name1', 'Address 1', 'Address 2', 'city', 'state', 'zip', 'cust po', 'ship method', 'notes', 'FFL#']
    end

    def header_fields
      [
        'H',
        @header[:customer],
        @header[:shipping][:name],
        @header[:shipping][:address_1],
        @header[:shipping][:address_2],
        @header[:shipping][:city],
        @header[:shipping][:state],
        @header[:shipping][:zip],
        @header[:purchase_order],
        @header[:shipping_method],
        @header[:notes],
        @header[:ffl],
      ]
    end

    def items_header
      ['LL', 'Item', 'Description', 'Qty', 'Price']
    end

    def item_fields(item)
      [
        'L',
        item[:item_number],
        item[:description],
        item[:quantity],
        item[:price],
      ]
    end

    def upload!
      connect(@options) do |ftp|
        ftp.chdir(ORDER_UPLOAD_DIR)
        ftp.puttextfile(@order_file.path, @order_filename)
      end
    end

  end
end
