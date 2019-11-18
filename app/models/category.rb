class Category < ApplicationRecord
  belongs_to :race
  has_many :race_results
  enum category: %i[zene u16 16-20 20-30 30-40 40-50 50 muskarci u9m u9w u11m u11w u13m u13w u15m u15w u17 17-19 19-30]

  def started?
    race_results.count > 0 && race_results.first.started_at.present?
  end

  def started_at
    race_results.count > 0 && race_results.first.started_at
  end

  def self.generics
    {'zene' => categories[:zene], 'muskarci' => categories[:muskarci]}
  end
end
