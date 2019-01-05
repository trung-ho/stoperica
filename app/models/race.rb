class Race < ApplicationRecord
  has_many :race_results
  has_many :categories
  has_many :racers, through: :race_results
  belongs_to :league, optional: true
  belongs_to :pool

  before_validation :parse_json

  enum race_type: [:mtb, :trcanje, :treking, :duatlon, :triatlon, :penjanje]

  attr_accessor :sorted_results
  attr_accessor :control_points_raw

  def assign_positions
    categories.each do |category|
      results = race_results
        .includes(:racer)
        .where(status: 3)
        .where(category: category)
        .select{ |rr| rr.lap_times.length > 0 }
        .sort_by{ |rr| [-rr.lap_times.length, rr.finish_time] }
      results.each_with_index do |rr, index|
        rr.update!(position: index + 1, finish_delta: rr.calc_finish_delta)
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

  def self.trail_points
    [
      100, 88, 78, 72, 68, 66, 64, 62, 60, 58, 56, 54, 52, 50, 48, 46, 44, 42,
      40, 38, 36, 34, 32, 30, 28, 26, 24, 22, 20, 18, 17, 16, 15, 14, 13, 12,
      11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
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
                    .select(&:points)
                    .sum(&:points)
        end
        data = clp.points
        data[id] = points
        clp.update(points: data)
      end
    elsif league&.xczld?
      clps = ClubLeaguePoint.where(league: league)
      clps
        .reject{ |clp| clp.club.points_in_race(self).zero? }
        .sort_by{ |clp| clp.club.points_in_race self }
        .each_with_index do |clp, index|
          data = clp.points
          data[id] = index + 1
          clp.update(points: data)
        end
    end

    if league&.xczld?
      race_results.update(points: nil)
      # za svaku kategoriju
      categories.each do |category|
        # nadi top 25 rezultata
        results = race_results
          .includes(:racer)
          .where(status: 3)
          .where(category: category)
          .select{ |rr| rr.lap_times.length > 0 }
          .sort_by{ |rr| [-rr.lap_times.length, rr.finish_time] }
          .first(25)

        results.each_with_index do |rr, index|
          # podijeli bodove
          rr.update!(points: Race.points[index])
        end
      end
    end

    if league&.running?
      finishers = race_results.includes(:racer).where(status: 3)
      men = finishers.where('racers.gender = 2').references(:racers).order(finish_time: :desc)
      women = finishers.where('racers.gender = 1').references(:racers).order(finish_time: :desc)

      men.each_with_index do |rr, index|
        rr.update(additional_points: index + 1)
      end

      women.each_with_index do |rr, index|
        rr.update(additional_points: index + 1)
      end

      categories.each do |category|
        results = race_results
          .includes(:racer)
          .where(status: 3)
          .where(category: category)
          .order(finish_time: :desc)
        results.each_with_index do |rr, index|
          rr.update(points: index + 1)
        end
      end

      ClubLeaguePoint.where(league: league).each_with_index do |clp, index|
        data = clp.points
        data[id] = clp.club.points_in_race self
        clp.update(points: data)
      end
    end

    if league&.trail?
      race_results.update(points: nil)
      # za svaku kategoriju
      categories.each do |category|
        # nadi top 25 rezultata
        results = race_results
          .includes(:racer)
          .where(status: 3)
          .where(category: category)
          .select{ |rr| rr.lap_times.length > 0 }
          .sort_by{ |rr| [-rr.lap_times.length, rr.finish_time] }

        results.each_with_index do |rr, index|
          # podijeli bodove
          rr.update!(points: Race.trail_points[index] || 1)
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

  def parse_json
    self.control_points = JSON.parse(control_points_raw) if control_points_raw.present?
  end

  def start_box_racers
    # for 10 racers per category
    # 1 box racer
    racers = league.racers.except([:zene, :u16])
    box_racers = []

    categories.each do |category|
      next if [:u16, :zene].include?(category.category)
      category_racers = racers[category.category]
      # 2 box places for 1-20 racers
      if category_racers.size <= 20
        box_places = 2
      # 3 box places for 21-30 etc
      else
        box_places = category_racers.size/10 + 1
      end
      box_racers << category_racers.sort_by{|_, v| v.sum{|r| -(r.points || 0)}}.collect{|_, v| v[0].racer}.first(box_places)
    end

    box_racers.flatten
  end
end
