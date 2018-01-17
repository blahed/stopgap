require 'pg'
require 'active_record'
require 'faker'

require 'stopgap/version'
require 'stopgap/cli'
require 'stopgap/table'
require 'stopgap/schema'

module Stopgap
  def self.schema(database, &block)
    schema = Schema.new(database)

    schema.instance_eval(&block)
    schema.populate
  end
end