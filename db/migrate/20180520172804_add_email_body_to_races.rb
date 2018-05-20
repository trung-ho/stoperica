class AddEmailBodyToRaces < ActiveRecord::Migration[5.0]
  def change
    add_column :races, :email_body, :text
  end
end
