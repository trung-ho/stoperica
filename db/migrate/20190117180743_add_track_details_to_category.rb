class AddTrackDetailsToCategory < ActiveRecord::Migration[5.1]
  def change
    add_column :categories, :track_length, :integer
    add_column :categories, :track_elevation, :integer
    add_column :categories, :track_descent, :integer
  end
end
