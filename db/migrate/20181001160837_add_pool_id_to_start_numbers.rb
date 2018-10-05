class AddPoolIdToStartNumbers < ActiveRecord::Migration[5.1]
  def change
    add_reference :start_numbers, :pool, foreign_key: true
  end
end
