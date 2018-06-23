class AddCountryToRacers < ActiveRecord::Migration[5.1]
  def change
    add_column :racers, :country, :string
  end
end
