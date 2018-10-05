class League < ApplicationRecord
  has_many :races

  enum league_type: [:xczld]
end
