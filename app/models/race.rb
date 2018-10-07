class Race < ApplicationRecord
  has_many :race_results
  has_many :categories
  has_many :racers, through: :race_results
  belongs_to :league, optional: true
  belongs_to :pool

  enum race_type: [:mtb, :trcanje, :treking, :duatlon, :triatlon, :penjanje]

  attr_accessor :sorted_results

  def assign_positions
    categories.each do |category|
      results = race_results
        .includes(:racer)
        .where(status: 3)
        .where(category: category)
        .select{ |rr| rr.lap_times.length > 0 }
        .sort_by{ |rr| [-rr.lap_times.length, rr.finish_time] }
      results.each_with_index do |rr, index|
        rr.update!(position: index + 1)
      end
    end
  end

  def to_csv
    CSV.generate() do |csv|
      csv << ['Startni broj', 'Pozicija', 'Ime', 'Prezime', 'Klub', 'Kategorija',
        'Velicina majice', 'Godiste', 'Prebivaliste', 'Email', 'Mobitel',
        'Vrijeme', 'Zaostatak', 'Status', 'Personal Best 21.1 km', 'UCI ID']
      race_results.each do |race_result|
        csv << race_result.to_csv
      end
    end
  end
end
