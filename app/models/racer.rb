class Racer < ApplicationRecord
  belongs_to :user, dependent: :delete, optional: true
  belongs_to :club, optional: true
  has_many :race_results, dependent: :destroy
  has_many :races, through: :race_results

  validates :email, presence: true, uniqueness: true
  validates :phone_number, presence: true, uniqueness: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def total_points
    race_results.sum { |rr| rr.points || 0 }
  end
end
