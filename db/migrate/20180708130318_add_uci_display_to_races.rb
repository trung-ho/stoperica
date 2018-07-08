class AddUciDisplayToRaces < ActiveRecord::Migration[5.1]
  def change
    add_column :races, :uci_display, :boolean
  end
end
