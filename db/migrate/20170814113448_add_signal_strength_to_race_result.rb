class AddSignalStrengthToRaceResult < ActiveRecord::Migration[5.0]
  def change
    add_column :race_results, :signal_strength, :integer, null: false, default: 1000
  end
end
