class AddMissedControlPointsToRaceResults < ActiveRecord::Migration[5.1]
  def change
    add_column :race_results, :missed_control_points, :integer, default: 0
  end
end
