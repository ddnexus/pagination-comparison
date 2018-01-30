# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


Faker::Config.random = Random.new(123)

1_000.times do |i|
  Dish.create name:        Faker::Food.dish,
              ingredient:  Faker::Food.ingredient,
              spice:       Faker::Food.spice
  print '.' if (i % 100).zero?
end

