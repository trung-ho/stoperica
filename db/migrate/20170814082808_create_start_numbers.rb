class CreateStartNumbers < ActiveRecord::Migration[5.0]
  def change
    create_table :start_numbers do |t|
      t.string :value
      t.string :tag_id

      t.timestamps
    end
  end
end
