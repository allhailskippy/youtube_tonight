class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.string :name
      t.string :email
      t.string :profile_image
      t.string :auth_hash
      t.integer :expires_at, :limit => 8
      t.userstamps
      t.timestamps
    end

    user = User.new
    user.provider = 'facebook'
    user.uid = '10156150575875244'
    user.save!
  end

  def down
    drop_table :users
  end
end
