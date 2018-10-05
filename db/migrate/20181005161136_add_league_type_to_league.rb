class AddLeagueTypeToLeague < ActiveRecord::Migration[5.1]
  def change
    add_column :leagues, :league_type, :integer
  end
end
