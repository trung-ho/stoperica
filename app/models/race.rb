class Race < ApplicationRecord
  has_many :race_results
  has_many :categories
  has_many :racers, through: :race_results

  def assign_positions
    categories.each do |category|
      results = race_results.includes(:racer).where(status: 3).where(category: category).sort{|x,y| x.finish_time <=> y.finish_time}.select{ |rr| rr.lap_times.length > 0 }
      results.each_with_index do |rr, index|
        rr.update!(position: index + 1)
      end
    end
  end

  def to_csv
    CSV.generate() do |csv|
      csv << ['Startni broj', 'Ime', 'Prezime', 'Klub', 'Kategorija', 'Velicina majice', 'Godiste', 'Prebivaliste', 'Email', 'Mobitel', 'Vrijeme', 'Status', 'Personal Best 21.1 km']
      race_results.each do |race_result|
        csv << race_result.to_csv
      end
    end
  end
end
