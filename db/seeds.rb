# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
user = User.new
user.provider = 'facebook'
user.uid = '10156150575875244'
user.creator_id = 1 # Self creation!
user.updater_id = 1
user.save!

Authorization.current_user = User.find(user.id)
role = Role.new
role.title = 'admin'
role.user_id = 1
role.creator_id = user.id
role.updater_id = user.id
role.save!
