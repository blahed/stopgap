require 'pry'

module Stopgap
  class Console
    PROMPT = [ proc { '>> ' }, proc { '.. ' }].freeze

    def self.start
      new
    end

    def self.start_dbconsole
      config = Schema.current.config

      # TODO: do we need to support adapters being so loosely set?

      case config[:adapter]
      when /\A(jdbc)?mysql/
        args = {
            host: '--host',
            port: '--port',
            socket: '--socket',
            username: '--user',
            password: '--password'
        }.map { |opt, arg| "#{arg}=#{config[opt]}" if config[opt] }.compact

        args << config[:database].to_s

        find_cmd_and_exec(['mysql', 'mysql5'], *args)
      when /\Apostgres|^postgis/
        ENV['PGUSER']     = config[:username] if config[:username]
        ENV['PGHOST']     = config[:host] if config[:host]
        ENV['PGPORT']     = config[:port].to_s if config[:port]
        ENV['PGPASSWORD'] = config[:password].to_s if config[:password]

        find_cmd_and_exec('psql', config[:database].to_s)
      end
    end

    def initialize
      load 'schema.rb'
      Schema.current.load
      Dir['models/*.rb'].each { |p| load p }

      listener = Listen.to('.', only: /\.rb\z/, relative: true) do |modified, added, removed|
        print "\a"
        load 'schema.rb'
        Dir['models/*.rb'].each { |p| load p }
        Schema.current.reload
      end

      listener.start

      Pry.start(binding,
        prompt: PROMPT,
        commands: commands,
        quiet: true
      )
    end

    private

    def commands
      command_set = Pry::CommandSet.new do
        command 'sql', 'Execute a SQL query' do |statement|
          result = ActiveRecord::Base.connection.execute(statement)

          output.puts result.fields
          output.puts result.values
        end

        command 'dbconsole', 'Open the database console' do |statement|
          Stopgap::Console.start_dbconsole
        end

        command 'help', 'Show a list of commands' do
          commands.each { |key, command| puts "  #{key.ljust(18)} #{command.description.capitalize}" }
        end

        command 'exit', 'Exit the Stopgap console' do
          exit
        end
      end

      command_set.add_command(Pry::Command::Hist)

      command_set
    end

    def self.find_cmd_and_exec(commands, *args)
      commands          = Array(commands)
      dirs_on_path      = ENV['PATH'].to_s.split(File::PATH_SEPARATOR)
      full_path_command = nil

      unless (ext = RbConfig::CONFIG['EXEEXT']).empty?
        commands = commands.map { |cmd| "#{cmd}#{ext}" }
      end

      found = commands.detect do |cmd|
        dirs_on_path.detect do |path|
          full_path_command = File.join(path, cmd)
          File.file?(full_path_command) && File.executable?(full_path_command)
        end
      end

      if found
        system full_path_command, *args
      else
        puts "Couldn't find database client: #{commands.join(', ')}. Check your $PATH and try again."
        exit 1
      end
    end
  end
end
