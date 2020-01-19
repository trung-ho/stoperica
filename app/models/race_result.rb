class RaceResult < ApplicationRecord

  belongs_to :racer
  belongs_to :race
  belongs_to :category
  belongs_to :start_number, optional: true

  validate :disallow_duplicates

  before_validation :set_finish_time
  after_save :calculate_climbing_positions, if: :saved_change_to_climbs?
  after_save :assign_league_number

  attr_accessor :racer_start_number

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

  def is_not_finsihed?
    finish_delta && (['krug', 'kruga', 'krugova'].include? finish_delta.split(' ').last)
  end

  def date_format
    race.millis_display? ? '%k:%M:%S.%2N' : '%k:%M:%S'
  end

  def pretty_status
    case status
    when 1
      registered_text
    when 2
      'Na startu'
    when 3
      if race.xco?
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

  def live_time
    return { time: '- -', control_point: nil } if lap_times.empty?
    label = race.xco? ? 'LAP' : 'KT'
    r_id = lap_times.last.dig('reader_id')
    time = control_point_time r_id
    control_point_name = 'Finish' if r_id.to_s == '0' && !race.xco?
    control_point_name = "LAP #{lap_times.length + 1}" if race.xco?
    if control_point_name.nil? && race.control_points
      cp_index = race.control_points.find_index{ |cp| cp['reader_id'] == r_id }
      if cp_index
        control_point_name = race.control_points[cp_index]['name'] || "#{label} #{cp_index + 1}"
      end
    end
    { time: time, control_point: control_point_name }
  end

  def reader_id_valid? reader_id
    lap_time = lap_times.find{|it| it['reader_id'].to_s == reader_id.to_s}
    return lap_time.present?
  end

  def control_point_time reader_id
    index = lap_times.rindex do |it|
      it.with_indifferent_access['reader_id'].to_s == reader_id.to_s
    end

    return '- -' if index.nil?
    lap_time index + 1
  end

  def lap_diff position = 0
    return nil if position < 2
    current = lap_millis(position)
    previous = lap_millis(position - 1)
    if current && previous
      diff = current - previous
      Time.at(diff).utc.strftime(date_format)
    else
      nil
    end
  end

  def control_point_diff reader_id
    index = race.control_points.find_index do |it|
      it.with_indifferent_access['reader_id'].to_s == reader_id.to_s
    end
    return nil if index.zero?
    previous_reader_id = race.control_points[index-1]['reader_id']
    return nil if previous_reader_id.nil?
    current = control_point_millis(reader_id)
    previous = control_point_millis(previous_reader_id)
    if current && previous
      diff = current - previous
      Time.at(diff).utc.strftime(date_format)
    else
      nil
    end
  end

  def control_point_millis reader_id = nil
    if reader_id.nil?
      lap_time = lap_times.last
    else
      lap_time = lap_times.find do |it|
        it.with_indifferent_access['reader_id'].to_s == reader_id.to_s
      end
    end
    time = lap_time.is_a?(Hash) ? lap_time.with_indifferent_access[:time] : lap_time
    time&.to_f
  end

  def lap_millis lap_position = nil
    return nil if lap_times.length.zero?
    return control_point_millis if race.xco? && lap_position.nil?
    unless lap_position
      if control_point_millis 0
        return control_point_millis 0
      else
        return control_point_millis nil
      end
    end
    lap_time = lap_times[lap_position - 1]
    return nil unless lap_time
    time = lap_time.is_a?(Hash) ? lap_time.with_indifferent_access[:time] : lap_time
    time&.to_f
  end

  # calling this method without lap param will return last lap time
  def lap_time lap_position = nil
    lap_time = lap_millis lap_position
    return '- -' if lap_time.nil? || status != 3

    start_time = started_at || race.started_at
    return '- -' unless start_time

    ended_at = Time.at(lap_time)
    seconds = ended_at - start_time
    Time.at(seconds).utc.strftime(date_format)
  end

  def set_finish_time
    self.finish_time = lap_time
  end

  def calc_finish_delta
    return '- -' unless status == 3
    return "- #{missed_control_points} #{lap_text(missed_control_points)}" unless missed_control_points.zero?

    reference_race_result = RaceResult.where(category: category, race: race, status: 3).order(:position).limit(1).first
    lap_diff = reference_race_result.lap_times.length - lap_times.length

    unless lap_times.empty?
      if lap_diff.zero?
        seconds = lap_millis - reference_race_result.lap_millis
        Time.at(seconds).utc.strftime("+#{date_format}")
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

  def insert_lap_time time, reader_id
    if race.xco?
      self.lap_times << { time: time, reader_id: reader_id }
    else
      index = lap_times.find_index{|it| it['reader_id'].to_s == reader_id.to_s}

      if index
        lap_times[index]['time'] = time
      else
        self.lap_times << { time: time, reader_id: reader_id }
      end
    end
    self.status = 3
    self.save!
    self
  end

  def to_csv
    [start_number&.value].tap { |h| h.push(racer.uci_id) if race.uci_display? } +
      [
        racer.last_name.mb_chars.upcase, racer.first_name,
        racer.club_name(race.uci_display), racer.country_name, category.try(:name),
        racer.shirt_size, racer.birth_date, racer.full_address, racer.email,
        racer.phone_number, racer.personal_best&.gsub(',', '.')&.gsub(';', ':')
      ]
  end

  def to_start_list_csv
    [start_number&.value].tap { |h| h.push(racer.uci_id) if race.uci_display? } +
      [racer.last_name.mb_chars.upcase, racer.first_name, racer.birth_date, racer.club_name(race.uci_display)]
  end

  def to_results_csv(uci_display = false)
    [position, start_number&.value].tap { |h| h.push(racer.uci_id) if uci_display || race.uci_display? } +
      [racer.last_name.mb_chars.upcase, racer.first_name, racer.club_name(race.uci_display), finish_time, finish_delta]
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
      if race.league.points[index]
        rr.update_columns(position: index + 1, points: race.league.points[index])
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

  def average_speed
    return unless status == 3
    return if finish_delta.include?('KT') || finish_delta.include?('LAP') # do not show speed of racers who haven't completed all control points
    return unless category.track_length && lap_millis
    start_time = started_at || race.started_at
    return unless start_time

    len = category.track_length.to_f/1000

    ended_at = Time.at(lap_millis)
    seconds = ended_at - start_time
    dur = seconds/3600
    "#{(len/dur).round 1} km/h"
  end

  def points_readable
    if(self.points.to_f % 1 == 0)
      return self.points.to_i
    else
      return self.points
    end
  rescue
    self.points
  end
  
end
