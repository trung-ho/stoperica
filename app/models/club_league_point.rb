class ClubLeaguePoint < ApplicationRecord
  belongs_to :club
  belongs_to :league

  before_save :calculate_total

  def calculate_total
    self.total = points.sum{ |k, v| v }
  end
end
