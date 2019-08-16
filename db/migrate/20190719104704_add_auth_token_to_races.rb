class AddAuthTokenToRaces < ActiveRecord::Migration[5.1]
  
  def up
    change_table :races do |t|
      t.string :auth_token
      t.boolean :skip_auth, default: false
      t.index :auth_token
    end

    Race.in_batches(of: 100).each_record do |race|
      race.update_columns skip_auth: true, auth_token: SecureRandom.hex(3)
    end
  end

  def down
    change_table :races do |t|
      t.remove_index :auth_token
      t.remove :auth_token
      t.remove :skip_auth
    end
  end

end
