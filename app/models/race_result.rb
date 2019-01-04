class RaceResult < ApplicationRecord
  belongs_to :racer
  belongs_to :race
  belongs_to :category
  belongs_to :start_number, optional: true
  attr_accessor :racer_start_number

  validate :disallow_duplicates
  before_validation :set_finish_time
  after_save :calculate_climbing_positions, if: :saved_change_to_climbs?
  after_save :assign_league_number

  def disallow_duplicates
    return if self.id
    errors.add(:racer, 'prijava vec postoji!') if RaceResult.exists?(racer: self.racer, race: self.race)
  end

  def registered_text
    if racer.gender == 2
      'Prijavljen'
    else
      'Prijavljena'
    end
  end

  def ended_text
    if racer.gender == 2
      'Završio'
    else
      'Završila'
    end
  end

  def lap_text(length)
    return 'KT' if race.treking?
    case length
    when 1
      'krug'
    when 2..4
      'kruga'
    else
      'krugova'
    end
  end

  def pretty_status
    case status
    when 1
      registered_text
    when 2
      'Na startu'
    when 3
      if race.laps
        "#{ended_text} #{lap_times.length} #{lap_text(lap_times.length)}"
      else
        ended_text
      end
    when 4
      'DNF'
    when 5
      'DSQ'
    when 6
      'DNS'
    else
      'Nepoznat'
    end
  end

  def last_lap_time
    time = lap_times.last.is_a?(String) ? lap_times.last : lap_times.last.with_indifferent_access[:time]
    time&.to_i
  end

  # TODO: refactor this and finish_time into one method
  def lap_time lap
    lap_time = lap_times[lap - 1]

    return '- -' if lap_time.nil?

    return '- -' unless status == 3

    start_time = started_at || race.started_at

    if !lap_times.empty? && start_time
      time = lap_time.is_a?(String) ? lap_time : lap_time.with_indifferent_access[:time]
      ended_at = Time.at(time.to_i)
      seconds = ended_at - start_time

      Time.at(seconds).utc.strftime('%k:%M:%S')
    else
      '- -'
    end
  end

  def calc_finish_time
    return '- -' unless status == 3

    start_time = started_at || race.started_at

    if !lap_times.empty? && start_time
      ended_at = Time.at(last_lap_time)
      seconds = ended_at - start_time

      Time.at(seconds).utc.strftime('%k:%M:%S')
    else
      '- -'
    end
  end

  def set_finish_time
    self.finish_time = calc_finish_time
  end

  def calc_finish_delta
    return '- -' unless status == 3
    reference_race_result = RaceResult.where(category: category, race: race, status: 3).order(:position).limit(1).first()
    lap_diff = reference_race_result.lap_times.length - lap_times.length
    if !lap_times.empty?
      if lap_diff == 0
        seconds = Time.at(last_lap_time) - Time.at(reference_race_result.last_lap_time)
        Time.at(seconds).utc.strftime('+%k:%M:%S')
      else
        "- #{lap_diff} #{lap_text(lap_diff)}"
      end
    else
      '- -'
    end
  end

  def total_points
    x = points || 0
    y = additional_points || 0
    x + y
  end

  def to_csv
    # ['Startni broj', 'Pozicija', 'Ime', 'Prezime', 'Klub',
    # 'Kategorija', 'Velicina majice',
    # 'Godiste', 'Prebivaliste', 'Email', 'Mobitel', 'Vrijeme', 'Zaostatak',
    # 'Status', 'Personal Best', 'UCI ID']
    [
      start_number&.value, position, racer.first_name, racer.last_name,
      racer.club.try(:name), category.try(:name), racer.shirt_size,
      racer.year_of_birth, racer.town, racer.email, racer.phone_number,
      finish_time, finish_delta, status, racer.personal_best, racer.uci_id
    ]
  end

  def calculate_climbing_positions
    # calculate positions based on points
    %w[q1 q2 final q].each do |level|
      res = race.race_results
                .select { |rr| rr.climbs.dig(level, 'points') && rr.category == category }
                .sort_by { |rr|
                  points = rr.climbs.dig(level, 'points')
                  if points.to_s.length == 1 || points.to_s.chomp('+').length == 1
                    points = "0#{points}"
                  end
                  [-points]
                }
                .reverse

      res.each_with_index do |rr, index|
        position = index + 1
        peers = res.take(position).select { |r| r.climbs[level]['points'] == rr.climbs[level]['points'] }
        if peers.size > 1
          positions = (position + 1)-peers.size..position
          avg = positions.inject(0.0) { |sum, el| sum + el } / positions.size
          avg = avg.round 2

          peers.each do |p|
            climbs = p.climbs
            climbs[level]['position'] = avg
            p.update_column(:climbs, climbs)
          end
        end

        # this is included in peers
        climbs = rr.climbs
        climbs[level]['position'] = avg || position
        rr.update_column(:climbs, climbs)
      end
    end

    calculate_climbing_scores
  end

  def calculate_climbing_scores
    # calc quali average points for results that have both quali climbs
    race
      .race_results
      .select{ |rr| rr.category == category }
      .select { |rr| rr.climbs.dig('q1', 'position') && rr.climbs.dig('q2', 'position') }
      .each do |rr|
      climbs = rr.climbs
      a = climbs['q1']['position']
      b = climbs['q2']['position']
      climbs['q'] = {} if climbs['q'].nil?
      if a && b
        climbs['q']['points'] = Math.sqrt(a * b).round 2
        rr.update_column(:climbs, climbs)
      end
    end

    # calculate positions in finals
    res = race
          .race_results.joins(:racer)
          .where('racers.country': :HR)
          .where(category: category)
          .select { |rr| rr.climbs.dig('final', 'position') }
    res.sort_by { |rr| [rr.climbs['final']['position'], rr.climbs['q']['position'], rr.climbs['final']['time']] }
      .each_with_index do |rr, index|
      if Race.lead_points[index]
        rr.update_columns(position: index + 1, points: Race.lead_points[index])
      else
        rr.update_column(:position, index + 1)
      end
    end

    fallback = race.race_results.count
    rest = race
           .race_results.joins(:racer)
           .where('racers.country': :HR)
           .where(category: category)
           .select { |rr| !rr.climbs.dig('final', 'position') }
    rest = rest.sort_by do |r|
      [
        r.climbs.dig('final', 'position') || fallback,
        r.climbs.dig('q', 'position') || fallback,
        r.climbs.dig('q2', 'position') || fallback,
        r.climbs.dig('q1', 'position') || fallback
      ]
    end
    rest.each_with_index do |rr, index|
      previous = rest[index - 1]
      if rr.climbs.dig('q', 'position').present? && previous&.climbs.dig('q', 'position') == rr.climbs.dig('q', 'position')
        rr.update_columns(position: previous.position, points: previous.points)
        next
      end

      if Race.lead_points[res.size + index]
        rr.update_columns(position: res.size + index + 1, points: Race.lead_points[res.size + index])
      else
        rr.update_column(:position, res.size + index + 1)
      end
    end
  end

  # assign same number throughout the league
  def assign_league_number
    if start_number.nil? && race.league&.xczld?
      race_ids = race.league.race_ids
      start_number = RaceResult
        .where(race_id: race_ids, racer: racer)
        .where.not(start_number_id: nil)
        .first&.start_number_id
      self.update_column(:start_number_id, start_number) unless start_number.nil?
    end
  end
end
