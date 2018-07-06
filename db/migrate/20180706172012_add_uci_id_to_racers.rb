class AddUciIdToRacers < ActiveRecord::Migration[5.1]
  def change
    add_column :racers, :uci_id, :string
  end
end
