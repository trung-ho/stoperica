class AddClubAdminFlagToRacers < ActiveRecord::Migration[5.1]
  
  def change
    change_table :racers do |t|
      t.boolean :club_admin, default: false
    end
  end

end
