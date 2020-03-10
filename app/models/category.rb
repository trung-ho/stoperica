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

  def self.xczld_categories
    {"zene" => 0, "u16" => 1, "u17" => 3, 
      "17-19" => 4, "16-20" => 5, "19-30" => 6, 
      "20-30" => 7, "30-40" => 8, "50" => 9, 
      "u15m" => 10, "u15w" => 11, "u13m" => 12, 
      "u13w" => 13, "u11m" => 14, "u11w" => 15, 
      "u9m" => 16, "u9w" => 17}
  end
end
