class League < ApplicationRecord
  has_many :races
  enum league_type: [:xczld]
  before_validation :generate_slug

  def to_param
     name.parameterize
  end

  def generate_slug
    self.slug = name.parameterize
  end
end
