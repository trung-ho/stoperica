class AddSendEmailToRaces < ActiveRecord::Migration[5.1]
  def change
    add_column :races, :send_email, :boolean
  end
end
