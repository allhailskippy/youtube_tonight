class AddRefreshTokenToUsers < ActiveRecord::Migration[4.2]
  def change
    change_table(:users) do |t|
      t.string :refresh_token, :after => :auth_hash
    end
  end
end
