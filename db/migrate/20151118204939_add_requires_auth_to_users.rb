class AddRequiresAuthToUsers < ActiveRecord::Migration
  def change
    change_table(:users) do |t|
      t.boolean :requires_auth, :default => true 
    end
  end
end
