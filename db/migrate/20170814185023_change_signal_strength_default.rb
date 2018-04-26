class ChangeSignalStrengthDefault < ActiveRecord::Migration[5.0]
  def change
    change_column_default :race_results, :signal_strength, -1000
  end
end
