require 'pry'

module Stopgap
  class Console
    PROMPT = [ proc { '>> ' }, proc { '.. ' }].freeze

    def self.start
      new
    end

    def initialize
      listener = Listen.to('.', only: /\.rb\z/, relative: true) do |modified, added, removed|
        print "\rSchema changed, updating db...   \n"
        $stdout.flush
        Schema.current.reload!
        print PROMPT.first.call
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
          ActiveRecord::Base.connection.execute(statement).values
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
  end
end