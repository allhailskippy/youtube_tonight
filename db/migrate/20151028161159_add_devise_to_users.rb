class AddDeviseToUsers < ActiveRecord::Migration
  def self.up
    change_table(:users) do |t|
      ## Database authenticatable
      #t.string :email,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
    end
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    remove_column :users, :sign_in_count rescue nil
    remove_column :users, :encrypted_password rescue nil
    remove_column :users, :current_sign_in_at rescue nil
    remove_column :users, :current_sign_in_ip rescue nil
    remove_column :users, :last_sign_in_ip rescue nil
    remove_column :users, :last_sign_in_at rescue nil
  end
end
