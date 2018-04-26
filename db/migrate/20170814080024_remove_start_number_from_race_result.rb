class RemoveStartNumberFromRaceResult < ActiveRecord::Migration[5.0]
  def change
    remove_column :race_results, :start_number
  end
end
