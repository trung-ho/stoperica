class AddFinishTimeToRaceResult < ActiveRecord::Migration[5.1]
  def change
    add_column :race_results, :finish_time, :string, default: '- -'
  end
end
