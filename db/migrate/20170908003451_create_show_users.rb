class CreateShowUsers < ActiveRecord::Migration[4.2]
  def up
    Show.reset_column_information

    create_table :show_users do |t|
      t.integer :show_id
      t.integer :user_id
      t.userstamps
      t.timestamps
    end

    Show.all.each do |show|
      show.users << User.find(show.hosts.split(','))
      show.save
    end

    remove_column :shows, :hosts
  end

  def down
    add_column :shows, :hosts, :string

    Show.reset_column_information

    Show.all.each do |show|
      show.hosts = show.users.collect(&:id).join(',')
      show.save
    end
      
    drop_table :show_users
  end
end
