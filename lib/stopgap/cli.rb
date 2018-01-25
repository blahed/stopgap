require 'fileutils'
require 'listen'

module Stopgap
  class CLI
    BANNER = <<~USAGE
      Usage:
        stopgap new PATH
        stopgap console PATH
      Description:
        Little database playground, napkin, slate, etc.
      Example:
        stopgap new playdabase
        cd playdabase
        # Edit your schema.rb
        stopgap console
    USAGE

    def self.run
      command = ARGV.shift

      case command
      when 'new', 'n'
        init
      when 'console', 'c'
        Console.start
      else
        puts BANNER
        exit
      end
    end

    def self.init
      path          = ARGV.first
      schema_path   = File.join(path, 'schema.rb')
      gemfile_path  = File.join(path, 'Gemfile')
      database_name = path.split('/').last
      template_path = File.expand_path('../../template', __FILE__)

      FileUtils.cp_r(template_path, path)

      schema = File.read(schema_path)

      File.open(schema_path, 'w') { |file| file.write schema.gsub('{{database}}', ":#{database_name}") }
      File.open(gemfile_path, 'w') { |file| file.write schema.gsub('{{version}}', "#{::Stopgap::VERSION}") }

      puts "\033[32mStopgap created...\033[0m"
      puts "  1. `cd #{path} && bundle install', then edit your schema.rb to get started"
      puts "  2. `stopgap console' to start your console and run queries"
    end
  end
end
