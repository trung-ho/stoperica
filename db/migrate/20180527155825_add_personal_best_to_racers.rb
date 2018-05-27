class AddPersonalBestToRacers < ActiveRecord::Migration[5.1]
  def change
    add_column :racers, :personal_best, :string
  end
end
