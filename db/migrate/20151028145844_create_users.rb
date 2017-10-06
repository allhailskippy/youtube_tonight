class CreateUsers < ActiveRecord::Migration[4.2]
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

  end

  def down
    drop_table :users
  end
end
