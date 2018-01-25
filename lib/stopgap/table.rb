module Stopgap
  class Table
    attr_accessor :name, :columns, :populate_count

    def initialize(name, options = {})
      @name           = name
      @columns        = {}
      @populate_count = options[:populate] || 0
    end

    def create
      ActiveRecord::Base.connection.create_table(name)

      columns.each do |column, attributes|
        ActiveRecord::Base.connection.add_column(name, column, attributes[:type], attributes[:options])
      end

      references.each do |reference, attributes|
        ActiveRecord::Base.connection.add_reference(name, reference, attributes[:options])
      end
    end

    def drop!
      ActiveRecord::Base.connection.drop_table(name, cascade: true)
    end

    def populate
      populatables = columns.reject {|_, c| c[:value].nil? }

      references.each do |reference, attributes|
        table = Stopgap::Schema.current.tables.find {|t| t.name == reference }
        # raise SchemaError
        id = rand(0..table.populate_count)
        populatables["#{reference}_id"] = id unless id.zero?
      end

      placeholders = "(#{Array.new(populatables.length, '?').join(',')})"
      column_names = populatables.keys.join(',')

      populate_count.times do
        values = populatables.values.map do |column|
          value = column[:value]
          case value
          when Array
            value.sample
          when Range
            rand(value)
          when Proc
            value.call
          else
            value
          end
        end

        statement = ActiveRecord::Base.send(:sanitize_sql_array, ["INSERT INTO #{name} (#{column_names}) VALUES #{placeholders}"].concat(values))

        ActiveRecord::Base.connection.execute(statement)
      end
    end

    %i[string text integer float decimal datetime timestamp time date binary boolean references].each do |type|
      define_method(type) do |*args|
        column  = args.shift
        options = args.empty? ? {} : args.shift

        columns[column] = {
          type: type,
          options: options,
          value: options.delete(:value)
        }
      end
    end

  end
end
