class AddRequiresAuthToUsers < ActiveRecord::Migration[4.2]
  def change
    change_table(:users) do |t|
      t.boolean :requires_auth, :default => true 
    end
  end
end
