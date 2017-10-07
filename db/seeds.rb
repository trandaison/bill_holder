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
    email: "boyz.ds@gmail.com",
    energy: [
      {date: "01/07/2017", quantity: 0},
      {date: "01/08/2017", quantity: 5},
      {date: "01/09/2017", quantity: 126}
    ],
    water: []
  },
  {
    pic: "Unknown",
    email: nil,
    energy: [],
    water: [
      {date: "01/07/2017", quantity: 0},
      {date: "01/08/2017", quantity: 5},
      {date: "01/09/2017", quantity: 126}
    ]
  },
  {
    pic: "Anh Tuyet",
    email: nil,
    energy: [
      {date: "01/07/2017", quantity: 2492},
      {date: "01/08/2017", quantity: 2497},
      {date: "01/09/2017", quantity: 2678}
    ],
    water: [
      {date: "01/07/2017", quantity: 1551},
      {date: "01/08/2017", quantity: 1559},
      {date: "01/09/2017", quantity: 1571}
    ]
  }
]

apartments.each do |params|
  if (apartment = Apartment.create(pic: params[:pic], email: params[:email]))
    if params[:energy]
      params[:energy].each do |e|
        apartment.meters.create meter_type: :energy, date: e[:date], quantity: e[:quantity]
      end
    end
    if params[:water]
      params[:water].each do |e|
        apartment.meters.create meter_type: :water, date: e[:date], quantity: e[:quantity]
      end
    end
  else
    puts "\n"
    puts apartment.errors.full_messages
  end
end
puts "\n"
