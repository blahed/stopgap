require 'active_record'

require 'stopgap/version'
require 'stopgap/console'
require 'stopgap/cli'
require 'stopgap/table'
require 'stopgap/schema'

module Stopgap
  class LogFormatter < Logger::Formatter
    def call(severity, time, progname, msg)
      "#{msg2str(msg)}\n"
    end
  end

  def self.schema(database, &block)
    schema = Schema.new(database)

    schema.instance_eval(&block)

    Schema.current = schema
  end

  def self.logger
    @logger ||= Logger.new(STDOUT, formatter: LogFormatter.new)
  end
end

ActiveRecord::Base.logger = Stopgap.logger