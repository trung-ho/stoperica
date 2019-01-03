class AddControlPointsToRaces < ActiveRecord::Migration[5.1]
  def change
    add_column :races, :control_points, :jsonb, array: true
  end
end
