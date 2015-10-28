class CreateRoles < ActiveRecord::Migration
  def up
    create_table :roles do |t|
      t.string :title
      t.integer :user_id
      t.userstamps
      t.timestamps
    end

    User.reset_column_information
    Authorization.current_user = User.find(1)
    role = Role.new
    role.title = 'admin'
    role.user_id = 1
    role.save!
  end

  def down
    drop_table :roles
  end
end
