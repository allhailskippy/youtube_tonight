class CreateSystemAdminUser < ActiveRecord::Migration
  def up
    User.reset_column_information
    Role.reset_column_information
    user = User.create(
      name: 'System Admin',
      email: 'noreply@youtubetonight.com',
      profile_image: 'https://lh4.googleusercontent.com/-2xkwN-nPcB0/AAAAAAAAAAI/AAAAAAAAAcM/GQNFIFgA9bw/photo.jpg',
      requires_auth: false
    )

    Role.create!(user_id: user.id, title: 'admin') 
  end

  def down
    User.find_by_name('System Admin').destroy
  end
end
