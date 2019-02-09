class AddPointsMultiplierToRaces < ActiveRecord::Migration[5.1]
  def up
    change_column :race_results, :points, :float
    change_column :race_results, :additional_points, :float
    add_column :races, :points_multiplier, :float, default: 1
  end

  def down
    remove_column :races, :points_multiplier
  end
end
