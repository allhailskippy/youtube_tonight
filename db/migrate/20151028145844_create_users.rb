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
      t.datetime :deleted_at, :default => nil
    end

    User.create_versioned_table
  end

  def down
    drop_table :users
    drop_table :user_versions
  end
end
