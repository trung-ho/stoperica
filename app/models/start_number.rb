class StartNumber < ApplicationRecord
  has_many :race_results
  belongs_to :race, optional: true
end
