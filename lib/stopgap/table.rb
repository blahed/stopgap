module Stopgap
  class Table
    def initialize(name, options = {})
      @name           = name
      @populate_count = options[:populate] || 0
      @populators     = {}

      ActiveRecord::Base.connection.create_table(name)
    end

    def populate
      placeholders = "(#{Array.new(@populators.length, '?').join(',')})"
      columns = @populators.keys.join(',')

      @populate_count.times do
        values = @populators.values.map do |val|
          case val
          when Array
            val.sample
          when Range
            rand(val)
          when Proc
            val.call
          else
            val
          end
        end

        statement = ActiveRecord::Base.send(:sanitize_sql_array, ["INSERT INTO #{@name} (#{columns}) VALUES #{placeholders}"].concat(values))

        ActiveRecord::Base.connection.execute(statement)
      end
    end

    %i[string text integer float decimal datetime timestamp time date binary boolean].each do |type|
      define_method(type) do |*args|
        column              = args.shift
        options             = args.empty? ? {} : args.shift
        @populators[column] = options.delete(:value) if options.has_key?(:value)

        ActiveRecord::Base.connection.add_column(@name, column, type, options)
      end
    end

  end
end
