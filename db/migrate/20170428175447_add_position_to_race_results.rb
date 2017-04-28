class AddPositionToRaceResults < ActiveRecord::Migration[5.0]
  def change
    add_column :race_results, :position, :integer
  end
end
