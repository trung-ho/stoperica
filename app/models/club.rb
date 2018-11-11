class Club < ApplicationRecord
  belongs_to :user, optional: true
  has_many :racers

  enum category: %i[biciklisticki triatlon atletski skole ostali penjacki trail-trekking trkacki-running]

  default_scope { order(name: :asc) }

  def points_in_race (race)
    RaceResult.includes(:racer).where(racer: racers, race: race).sum(:points)
  end
end
