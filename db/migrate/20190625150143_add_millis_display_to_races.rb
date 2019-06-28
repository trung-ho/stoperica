class AddMillisDisplayToRaces < ActiveRecord::Migration[5.1]
  def change
    add_column :races, :millis_display, :boolean
  end
end
