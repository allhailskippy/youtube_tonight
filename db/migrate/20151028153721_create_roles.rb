class CreateRoles < ActiveRecord::Migration[4.2]
  def up
    create_table :roles do |t|
      t.string :title
      t.integer :user_id
      t.userstamps
      t.timestamps
    end
  end

  def down
    drop_table :roles
  end
end
