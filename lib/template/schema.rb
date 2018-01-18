Stopgap.schema {{database}} do
  # adapter 'pg'
  # host 'localhost'
  # username 'myuser'
  # password 'mypassword'

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