class Race < ApplicationRecord
  has_many :race_results
  has_many :categories
  has_many :racers, through: :race_results
  has_many :start_numbers, through: :race_results
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

  def self.points
    [
      250, 200, 160, 150, 140, 130, 120, 110, 100, 90, 80, 75, 70, 65, 60, 55,
      50, 45, 40, 35, 30, 25, 20, 15, 10
    ]
  end

  def self.lead_points
    [
      100, 80, 65, 55, 51, 47, 43, 40, 37, 34, 31, 28, 26, 24, 22, 20, 18, 16,
      14, 12, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
    ]
  end

  def assign_points
    if league&.lead?
      clps = ClubLeaguePoint.where(league: league)
      clps.each do |clp|
        points = 0
        categories.each do |c|
          points += c.race_results.joins(:racer)
                    .where('racers.club_id = ?', clp.club.id)
                    .order(position: :asc)
                    .first(5)
                    .sum(&:points)
        end
        data = clp.points
        data[id] = points
        clp.update(points: data)
      end
    end

    if league&.xczld?
      # za svaku kategoriju
      categories.each do |category|
        # nadi top 25 rezultata
        results = race_results.includes(:racer)
          .where(status: 3).where(category: category)
          .sort{|x,y| x.finish_time <=> y.finish_time}
          .select{ |rr| rr.lap_times.length > 0 }.first(25)

        results.each_with_index do |rr, index|
          # podijeli bodove
          rr.update!(points: Race.points[index])
        end
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
