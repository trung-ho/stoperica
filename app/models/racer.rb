class Racer < ApplicationRecord
  belongs_to :user, dependent: :delete, optional: true
  belongs_to :club, optional: true
  has_many :race_results, dependent: :destroy
  has_many :races, through: :race_results

  validates :email, presence: true, uniqueness: true
  validates :phone_number, presence: true, uniqueness: true

  paginates_per 100

  def full_name
    "#{first_name} #{last_name}"
  end

  def total_points
    race_results.sum { |rr| rr.points || 0 }
  end

  def country_flag
    if country.present?
      Country.new(country).emoji_flag
    else
      ''
    end
  end

  def country_name
    if country.present?
      Country.new(country).name
    else
      ''
    end
  end
end
