class AddRefreshTokenToUsers < ActiveRecord::Migration
  def change
    change_table(:users) do |t|
      t.string :refresh_token, :after => :auth_hash
    end
  end
end
