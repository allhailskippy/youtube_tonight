class CreatePlayers < ActiveRecord::Migration[5.0]
  def change
    create_table :players do |t|
      t.integer :user_id
      t.string :player_id
      t.string :broadcast_id, default: nil
      t.integer :registered_count, default: 0
      t.userstamps
      t.timestamps
    end
  end
end
