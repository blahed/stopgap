module Stopgap
  class Schema

    class << self
      attr_accessor :current
    end

    attr_reader :database, :adapter, :host, :username, :password, :tables

    def initialize(database)
      @database  = database
      @adapter   = 'postgresql'
      @host      = 'localhost'
      @tables    = []
    end

    def adapter(adapter)
      @adapter = adapter
    end

    def host(host)
      @host = host
    end

    def username(username)
      @username = username
    end

    def password(password)
      @password = password
    end

    def config
      {
        adapter:  @adapter,
        host:     @host,
        username: @username,
        password: @password,
        database: @database
      }
    end

    def exists?
      ActiveRecord::Base.connection
    rescue ActiveRecord::NoDatabaseError
      false
    else
      true
    end

    def connect!
      silenced do
        ActiveRecord::Base.establish_connection(config.merge(database: 'postgres'))

        ActiveRecord::Base.connection.drop_database(config[:database]) if exists?
        ActiveRecord::Base.connection.create_database(config[:database])
        ActiveRecord::Base.remove_connection
        ActiveRecord::Base.establish_connection(config)
      end
    end

    def connected?
      ActiveRecord::Base.connected?
    end

    def table(name, options = {}, &block)
      table = Table.new(name, options)

      table.instance_eval(&block)
      @tables << table
    end

    def load
      connect! unless connected?

      silenced do
        @tables.each do |table|
          table.create
          table.populate
        end
      end
    end

    def reload
      silenced do
        @tables.each do |table|
          table.drop!
          table.create
          table.populate
        end
      end
    end

    private

    def silenced(&block)
      ::ActiveRecord::Base.logger = nil
      block.call
      ::ActiveRecord::Base.logger = ::Stopgap.logger
    end

  end
end
