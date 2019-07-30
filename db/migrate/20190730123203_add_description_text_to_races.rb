class AddDescriptionTextToRaces < ActiveRecord::Migration[5.1]

  def change
    change_table :races do |t|
      t.text :description_text
    end
  end

end
