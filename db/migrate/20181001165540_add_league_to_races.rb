class AddLeagueToRaces < ActiveRecord::Migration[5.1]
  def change
    add_reference :races, :league, foreign_key: true
  end
end
