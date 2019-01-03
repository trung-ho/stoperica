class CreateRaceAdmins < ActiveRecord::Migration[5.1]
  def change
    create_table :race_admins do |t|
      t.belongs_to :racer, foreign_key: true
      t.belongs_to :race, foreign_key: true

      t.timestamps
    end
  end
end
