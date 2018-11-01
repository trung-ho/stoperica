class AddCategoryTypeToCategories < ActiveRecord::Migration[5.1]
  def change
    add_column :categories, :category, :integer
  end
end
