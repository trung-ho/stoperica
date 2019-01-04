class Category < ApplicationRecord
  belongs_to :race
  has_many :race_results
  enum category: %i[zene u16 16-20 20-30 30-40 40-50 50 muskarci]

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
