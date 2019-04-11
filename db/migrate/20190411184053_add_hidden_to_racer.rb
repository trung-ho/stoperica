class AddHiddenToRacer < ActiveRecord::Migration[5.1]
  def change
    add_column :racers, :hidden, :boolean, default: false
  end
end
