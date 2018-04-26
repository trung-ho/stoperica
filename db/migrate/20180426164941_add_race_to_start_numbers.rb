class AddRaceToStartNumbers < ActiveRecord::Migration[5.0]
  def change
    add_reference :start_numbers, :race, foreign_key: true
  end
end
