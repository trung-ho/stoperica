class AddFinishDeltaToRaceResult < ActiveRecord::Migration[5.1]
  def change
    add_column :race_results, :finish_delta, :string, default: '- -'
  end
end
