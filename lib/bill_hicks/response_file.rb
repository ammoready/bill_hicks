module BillHicks
  class ResponseFile < Base

    attr_reader :credentials
    attr_reader :filename

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

    # Is the file a '855 Purchase Order Acknowledgement'?
    def ack?
      content.start_with?("ACK")
    end

    # Is the file a '856 Advance Shipping Notice'?
    def asn?
      content.start_with?("ASN")
    end

    # Use '#gettextfile' to read file contents as a string
    def content
      return @content if @content
      connect(@credentials) do |ftp|
        ftp.chdir(BillHicks.config.full_response_dir)
        @content = ftp.gettextfile(@filename, nil)
      end
    end

    # Convert to easily readable key-value pairs
    def to_json
      if corrupt_asn?
        CSV.parse(content.gsub("Price|", ""), headers: true, col_sep: "|").
          map { |x| x.to_h }.
          group_by { |x| x["PO Number"] }
      else
        CSV.parse(content, headers: true, col_sep: "|").
          map { |x| x.to_h }.
          group_by { |x| x["PO Number"] }
      end
    end

    private

    def corrupt_asn?
      return false if ack?
      lines = content.lines.map(&:chomp)
      if lines[0].split("|").length != lines[1].split("|").length
        puts "Notice: ASN file is malformed! (#{filename})"
        true
      else
        false
      end
    end

  end

end
