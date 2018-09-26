class AddClimbsToRaceResult < ActiveRecord::Migration[5.1]
  def change
    add_column :race_results, :climbs, :jsonb, default: {}
  end
end
