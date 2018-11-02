class CreateClubLeaguePoints < ActiveRecord::Migration[5.1]
  def change
    create_table :club_league_points do |t|
      t.belongs_to :club, foreign_key: true
      t.belongs_to :league, foreign_key: true
      t.jsonb :points, default: {}
      t.integer :total
      t.timestamps
    end
  end
end
