module BillHicks
  class ResponseFile < Base

    attr_reader :content
    attr_reader :credentials
    attr_reader :filename

    FILE_TYPES = {
      "ACK" => "Purchase Order Acknowledgement",
      "ASN" => "Advance Shipping Notice"
    }

    # @option options [String] :username *required*
    # @option options [String] :password *required*
    # @option options [String] :filename *required*
    def initialize(options = {})
      requires!(options, :username, :password, :filename)

      @credentials = options.select { |k, v| [:username, :password].include?(k) }
      @filename    = options[:filename]
    end

    # Return list of '855 Purchase Order Acknowledgement' files
    # @option options [String] :username *required*
    # @option options [String] :password *required*
    def self.all(options = {})
      requires!(options, :username, :password)

      Base.connect(options) do |ftp|
        ftp.chdir(BillHicks.config.full_response_dir)
        ftp.nlst("*.txt")
      end
    end

    def content
      return @content if @content
      connect(@credentials) do |ftp|
        ftp.chdir(BillHicks.config.full_response_dir)
        @content = ftp.gettextfile(@filename, nil)
      end
    end

    def to_json
      CSV.parse(content, headers: true, col_sep: "|").
        map { |x| x.to_h }.
        group_by { |x| x["PO Number"] }
    end

  end

end
