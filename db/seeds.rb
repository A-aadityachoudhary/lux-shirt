# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Create admin user if none exists
if User.find_by(email: 'admin@luxshirt.com').nil?
  User.create!(
    name: 'Admin',
    email_address: 'admin@gmail.com',
    password: '992838',
    role: 'admin'
  )
  puts "Admin user created!"
end