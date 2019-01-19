class AddLocationUrlToRaces < ActiveRecord::Migration[5.1]
  def change
    add_column :races, :location_url, :string
  end
end
