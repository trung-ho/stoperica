class AddRegistrationThresholdDateToRaces < ActiveRecord::Migration[5.0]
  def change
    add_column :races, :registration_threshold, :datetime
  end
end
