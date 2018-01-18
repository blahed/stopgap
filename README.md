# Stopgap

Stopgap is a simple tool that allows you to build a database playground–think of it as a napkin you design and prototype a schema on. When you make a change and save it, the database will be dropped and recreated to match your new schema. You can even populate the database automatically with data to make writing and testing queries painless.

Here's an example of how easy it is to get started with a schema, and populate it with data:

```ruby
Stopgap.schema :playdabase do

  table :users, populate: 25 do |t|
    t.string :name, value: -> { Faker::Name.name }
    t.integer :age, value: 1..25
    t.string :sex, value: ['male', 'female']
    t.reference :company, value: 1..5
  end

  table :companies, populate: 5 do |t|
    t.string :name, value: -> { Faker::Company.name }
    t.string :ein, value: -> { Faker::Company.ein }
  end

end
```

Then you can use the console to query and inspect the data:

```ruby
>> sql "SELECT * FROM users WHERE company_id = 1"
```


## Installation

    $ gem install stopgap

## Usage

To create a new stopgap playground:

    $ stopgap new playdabase

Start a console to query data:

    $ cd playdabase
    $ bundle install
    $ stopgap console

As you make changes to your schema file changes will be automatically applied and your models will be reloaded as well.

Start a db console session:

    $ stopgap dbconsole

Changes will not be

## Schema development

Stopgap uses ActiveRecord, and methods used in schema definition are proxied to ActiveRecord. The stopgap schema API extends these methods by adding a `populate` option that is used for population, otherwise options are passed through to AR.

* `table`      -> `create_table`
* `join_table` -> `create_join_table`
* `index`      -> `create_index`

### Columns

Defining a table's columns is AR based, the only extension is the `value` option which is used for population:

```ruby
table :users, populate: 25 do |t|
  t.string :name, value: -> { Faker::Name.name }
  t.integer :age, value: 1..25
  t.string :sex, value: ['male', 'female']
  t.reference :company, value: 1..5
end
  ```

## Population

Populating data using Stopgap is pretty straightforward. Each table definition accepts a `population` option with an integer for the count of records to populate. When defining your table, each column accepts a `value` option for setting the value of the column. The `value` option can be the actual value you'd like to use, or an option `Proc`, `Range`, or `Array`. They're used as followed:

* `Proc` objects will be called, setting the value of the column to the result of the proc
* `Array` objects will be `sample`ed to determine a random value from the array
* `Range` objects will be passed to `rand()` to determine a random value from the range

## Development

Run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/blahed/stopgap.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
