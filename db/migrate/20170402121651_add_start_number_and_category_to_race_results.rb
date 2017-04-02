class AddStartNumberAndCategoryToRaceResults < ActiveRecord::Migration[5.0]
  def change
    add_column :race_results, :start_number, :integer
    add_reference :race_results, :category, index: true
  end
end
