class AddLockRaceResultsToRaces < ActiveRecord::Migration[5.1]
  def change
    add_column :races, :lock_race_results, :boolean
  end
end
