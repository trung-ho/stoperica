class AddAdditionalPointsToRaceResult < ActiveRecord::Migration[5.1]
  def change
    add_column :race_results, :additional_points, :integer
  end
end
