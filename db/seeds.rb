# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
user = User.create!(
  name: 'System Admin',
  email: 'noreply@youtubetonight.com',
  profile_image: 'https://lh4.googleusercontent.com/-2xkwN-nPcB0/AAAAAAAAAAI/AAAAAAAAAcM/GQNFIFgA9bw/photo.jpg',
  requires_auth: true,
  skip_playlist_import: true
)
role = Role.create!(user_id: user.id, title: 'admin') 
user.update_attribute(:requires_auth, false)
