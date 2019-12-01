# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Stripe::Plan.list['data'].each do |plan|
  next if Plan.exists?(stripe_id: plan['id'])

  Plan.create \
    stripe_id: plan['id'],
    name: plan['nickname'],
    interval: plan['interval'],
    amount: plan['amount']
end
