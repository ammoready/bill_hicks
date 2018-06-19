module BillHicks
  class FTP

    attr_reader :connection

    def initialize(credentials)
      @connection ||= Net::FTP.new(BillHicks.config.ftp_host)
      @connection.passive = true
      self.login(credentials[:username], credentials[:password])
    end

    def login(username, password)
      @connection.login(username, password)
    rescue Net::FTPPermError
      raise BillHicks::NotAuthenticated
    end

    def close
      @connection.close
    end

  end
end
