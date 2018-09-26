class AddRaceTypeToRaces < ActiveRecord::Migration[5.1]
  def change
    add_column :races, :race_type, :integer, default: 0
  end
end
