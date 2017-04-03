class AddShirtSizeToRacers < ActiveRecord::Migration[5.0]
  def change
    add_column :racers, :shirt_size, :string
  end
end
