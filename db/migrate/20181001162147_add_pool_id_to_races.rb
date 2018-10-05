class AddPoolIdToRaces < ActiveRecord::Migration[5.1]
  def change
    add_reference :races, :pool, foreign_key: true
  end
end
