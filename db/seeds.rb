# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
apartments = [
  {
    pic: "Son Tran",
    email: "boyz.ds@gmail.com"
  },
  {
    pic: "Unknown",
    email: nil
  },
  {
    pic: "Anh Tuyet",
    email: nil
  }
]

apartments.each do |params|
  unless apartment = Apartment.create(params)
    puts "\n"
    puts apartment.errors.full_messages
  end
end
puts "\n"
