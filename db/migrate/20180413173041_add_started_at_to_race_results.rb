class AddStartedAtToRaceResults < ActiveRecord::Migration[5.0]
  def change
    add_column :race_results, :started_at, :datetime
  end
end
