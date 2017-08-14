class AddStartNumberToRaceResult < ActiveRecord::Migration[5.0]
  def change
    add_reference :race_results, :start_number, index: true
  end
end
