class AddAlternateTagIdToStartNumber < ActiveRecord::Migration[5.1]
  def change
    add_column :start_numbers, :alternate_tag_id, :string
  end
end
