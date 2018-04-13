class Category < ApplicationRecord
  belongs_to :race
  has_many :race_results

  def started?
    race_results.count > 0 && race_results.first.started_at.present?
  end
end
