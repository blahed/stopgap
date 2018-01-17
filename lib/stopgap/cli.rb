require 'fileutils'

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
      stopgap c
    USAGE

    def self.run
      command = ARGV.shift

      case command
      when 'new', 'n'
        init
      when 'console', 'c'
        start_console
      else
        puts BANNER
        exit
      end
    end

    def self.init
      name    = ARGV.first
      example = <<~EXAMPLE
      Stopgap.schema(:#{name.split('/').last}) do

        table :users, populate: 25 do |t|
          t.string "name", value: -> { Faker::Name.name }
          t.integer "age", value: 1..25
          t.string "sex", value: ['male', 'female']
          t.integer "company_id", value: 1..5
        end

        table :companies, populate: 5 do |t|
          t.string "name", value: -> { Faker::Company.name }
          t.string "ein", value: -> { Faker::Company.ein }
        end
      end
      EXAMPLE

      FileUtils.mkdir_p(name)

      File.open("#{name}/schema.rb", 'w') do |file|
        file.write(example)
      end
    end

    def self.start_console
      IRB.start('schema.rb')
    end
  end
end