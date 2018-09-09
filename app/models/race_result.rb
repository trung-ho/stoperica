class RaceResult < ApplicationRecord
  belongs_to :racer
  belongs_to :race
  belongs_to :category
  belongs_to :start_number, optional: true
  attr_accessor :racer_start_number

  validate :disallow_duplicates
  # TODO: don't do this for other races
  after_save :calculate_climbing_positions

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
      "#{ended_text} #{lap_times.length} #{lap_text(lap_times.length)}"
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

  # TODO: refactor this and finish_time into one method
  def lap_time lap
    lap_time = lap_times[lap - 1]

    return '- -' if lap_time.nil?

    return '- -' unless status == 3

    start_time = started_at || race.started_at

    if !lap_times.empty? && start_time
      ended_at = Time.at(lap_time.to_i)
      seconds = ended_at - start_time

      Time.at(seconds).utc.strftime('%k:%M:%S')
    else
      '- -'
    end
  end

  def finish_time
    return '- -' unless status == 3

    start_time = started_at || race.started_at

    if !lap_times.empty? && start_time
      ended_at = Time.at(lap_times.last.to_i)
      seconds = ended_at - start_time

      Time.at(seconds).utc.strftime('%k:%M:%S')
    else
      '- -'
    end
  end

  def finish_delta
    return '- -' unless status == 3
    reference_race_result = RaceResult.joins(:racer).where(category: category, race: race, status: 3).order(:position).limit(1).first()
    lap_diff = reference_race_result.lap_times.length - lap_times.length
    if !lap_times.empty?
      if lap_diff == 0
        seconds = Time.at(lap_times.last.to_i) - Time.at(reference_race_result.lap_times.last.to_i)
        Time.at(seconds).utc.strftime('+%k:%M:%S')
      else
        "- #{lap_diff} #{lap_text(lap_diff)}"
      end
    else
      '- -'
    end
  end

  def to_csv
    # ['Startni broj', 'Pozicija', 'Ime', 'Prezime', 'Klub',
    # 'Kategorija', 'Velicina majice',
    # 'Godiste', 'Prebivaliste', 'Email', 'Mobitel', 'Vrijeme', 'Razlika',
    # 'Status', 'Personal Best', 'UCI ID']
    [
      start_number&.value, position, racer.first_name, racer.last_name,
      racer.club.try(:name), category.try(:name), racer.shirt_size,
      racer.year_of_birth, racer.town, racer.email, racer.phone_number,
      finish_time, finish_delta, status, racer.personal_best, racer.uci_id
    ]
  end

  def calculate_climbing_positions
    # calc quali average points for results that have both quali climbs
    race
      .race_results
      .select { |rr| rr.climbs['q1'] && rr.climbs['q2'] }
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

    # calculate positions based on points
    %w[q1 q2 final q].each do |level|
      res = race.race_results
                .select { |rr| rr.climbs[level] && rr.climbs[level]['points'] }
                .sort_by { |rr| [rr.climbs[level]['points']] }

      res.each_with_index do |rr, index|
        position = index + 1
        peers = res.take(position).select { |r| r.climbs[level]['points'] == rr.climbs[level]['points'] }
        if peers.size > 1
          positions = peers.collect { |p| p.climbs.dig(level, 'position') }
          avg = positions.inject(0.0) { |sum, el| sum + (el || position - peers.size + 1) } / positions.size

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

    # calculate positions in finals
    res = race
      .race_results
      .select { |rr| rr.climbs.dig('final', 'position') }
    res.sort_by { |rr| [rr.climbs['final']['position'], rr.climbs['final']['time']] }
      .each_with_index do |rr, index|
      rr.update_column(:position, index + 1)
    end
  end
end
