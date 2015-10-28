class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :facebook_id
      t.string :display_name
      t.string :name
      t.string :email
      t.string :profile_image
      t.string :auth_hash
      t.integer :expires_at, :limit => 8
      t.timestamps
    end
  end

  def down
    drop_table :users
  end
end
