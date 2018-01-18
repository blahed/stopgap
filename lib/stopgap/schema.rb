module Stopgap
  class Schema

    class << self
      attr_accessor :current
    end

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
      ActiveRecord::Base.establish_connection(config.merge(database: 'postgres'))

      ActiveRecord::Base.connection.drop_database(config[:database]) if exists?
      ActiveRecord::Base.connection.create_database(config[:database])
      ActiveRecord::Base.remove_connection
      ActiveRecord::Base.establish_connection(config)
    end

    def connected?
      ActiveRecord::Base.connected?
    end

    def table(name, options = {}, &block)
      connect! unless connected?

      table = Table.new(name, options)

      table.instance_eval(&block)
      @tables << table
    end

    def populate
      @tables.each do |table|
        table.populate
      end
    end

    def reload!
      @tables.each do |table|
        table.drop!
        table.populate
      end
    end

  end
end
