class Club < ApplicationRecord
  belongs_to :user, optional: true
  has_many :racers

  enum category: %i[biciklisticki triatlon atletski skole ostali]

  default_scope { order(name: :asc) }
end
