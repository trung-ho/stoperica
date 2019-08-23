class Race < ApplicationRecord

  belongs_to :league, optional: true
  belongs_to :pool
  
  has_many :race_results
  has_many :categories
  has_many :racers, through: :race_results

  before_validation :parse_json
  before_save :set_auth_token

  enum race_type: [:mtb, :trcanje, :treking, :duatlon, :triatlon, :penjanje, :xco, :road]

  attr_accessor :control_points_raw

  PAGINATE_PER = 12
  paginates_per PAGINATE_PER

  def assign_positions
    categories.each do |category|
      results = race_results
        .includes(:racer)
        .where(status: 3)
        .where(category: category)
        .select{ |rr| rr.lap_times.length > 0 }
        .sort_by{ |rr| [rr.missed_control_points, -rr.lap_times.length, rr.lap_time] }
      results.each_with_index do |rr, index|
        rr.update!(position: index + 1, finish_delta: rr.calc_finish_delta)
      end
    end
  end

  def assign_points
    # assign category points
    if league&.xczld? || league&.trail?
      race_results.update(points: nil)
      limit = league.xczld? ? 25 : nil
      fallback_points = league.xczld? ? 0 : 1

      categories.each do |category|
        results = race_results
          .includes(:racer)
          .where(status: 3)
          .where(category: category)
          .order(:position)
          .limit(limit)

        results.each_with_index do |rr, index|
          points = (league.points[index] || fallback_points) * points_multiplier
          rr.update!(points: points)
        end
      end
    end

    # assign lead club league points
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
    end

    # assign xczld club league points
    if league&.xczld?
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

    # assign running category, overall and club league points
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
  end

  def adjust_finish_time
    res = race_results.where(status: 3).order(:position)
    res.each_with_index do |rr, index|
      next if index.zero?
      prev = res[index - 1]
      next unless prev.lap_millis && rr.lap_millis
      diff = prev.lap_millis - rr.lap_millis
      if diff < 1.1
        rr.update_columns(finish_time: prev.finish_time, finish_delta: prev.finish_delta)
      end
    end
  end

  def to_csv
    CSV.generate do |csv|
      csv << ['Startni broj'].tap { |h| h.push('UCI ID') if uci_display? } + ['Prezime', 'Ime',
        'Klub', 'Država', 'Kategorija', 'Majica', 'Datum rodenja', 'Prebivalište',
        'Email', 'Mobitel', 'Personal Best']
      race_results.each do |race_result|
        csv << race_result.to_csv
      end
    end
  end

  def to_xlsx
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "Svi podaci") do |sheet|
        sheet.add_row ['Startni broj'].tap { |h| h.push('UCI ID') if uci_display? } + ['Prezime', 'Ime',
          'Klub', 'Država', 'Kategorija', 'Majica', 'Datum rodenja', 'Prebivalište',
          'Email', 'Mobitel', 'Personal Best']
        race_results.each do |race_result|
          sheet.add_row race_result.to_csv
        end
      end
    end.to_stream.string
  end

  def to_start_list_csv
    CSV.generate do |csv|
      csv << ['Startni broj'].tap { |h| h.push('UCI ID') if uci_display? } + ['Prezime', 'Ime',
        'Datum rodenja', 'Klub']
      categories.each do |category|
        next if sorted_results[category].count.zero?
        csv << [category.name]
        sorted_results[category].each do |race_result|
          csv << race_result.to_start_list_csv
        end
      end
    end
  end

  def to_start_list_xlsx
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "Startna lista") do |sheet|
        sheet.add_row ['Startni broj'].tap { |h| h.push('UCI ID') if uci_display? } + ['Prezime', 'Ime',
          'Datum rodenja', 'Klub']
        categories.each do |category|
          next if sorted_results[category].count.zero?
          sheet.add_row [category.name]
          sorted_results[category].each do |race_result|
            sheet.add_row race_result.to_start_list_csv
          end
        end
      end
    end.to_stream.string
  end

  def to_results_csv(uci_display = false)
    CSV.generate do |csv|
      csv << ['Pozicija', 'Startni broj'].tap { |h| h.push('UCI ID') if uci_display? || uci_display } + 
        ['Prezime', 'Ime', 'Klub', 'Vrijeme', 'Zaostatak']
      categories.each do |category|
        next if sorted_results[category].count.zero?
        csv << [category.name]
        sorted_results[category].each do |race_result|
          csv << race_result.to_results_csv(uci_display)
        end
      end
    end
  end

  def to_results_xlsx(uci_display = false)
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "Rezultati") do |sheet|
        sheet.add_row ['Pozicija', 'Startni broj'].tap { |h| h.push('UCI ID') if uci_display? || uci_display } + 
          ['Prezime', 'Ime', 'Klub', 'Vrijeme', 'Zaostatak']
        categories.each do |category|
          next if sorted_results[category].count.zero?
          sheet.add_row [category.name]
          sorted_results[category].each do |race_result|
            sheet.add_row race_result.to_results_csv(uci_display)
          end
        end
      end
    end.to_stream.string
  end

  def parse_json
    self.control_points = JSON.parse(control_points_raw) if control_points_raw.present?
  end

  def sorted_results(unsorted = false)
    return if unsorted
    if penjanje?
      fallback = race_results.count
      sorted_results = race_results.where.not(position: nil).order(:position)
      rest = race_results.where(position: nil)
      rest = rest.sort_by do |r|
        [
          r.climbs.dig('final', 'position') || fallback,
          r.climbs.dig('q', 'position') || fallback,
          r.climbs.dig('q2', 'position') || fallback,
          r.climbs.dig('q1', 'position') || fallback
        ]
      end
      sorted_results += rest
      sorted_results = sorted_results
    else
      sorted_results = {}
      categories.each do |category|
        category_results = race_results.where(category: category)
        if started_at.nil?
          sorted_results[category] = category_results.order(created_at: :desc)
        else
          sorted_results[category] = category_results.where.not(position: nil).order(:position) +
            category_results.where(position: nil).order(status: :desc)
        end
      end
    end
    sorted_results
  end

  def sort_results_by_distance
    sorted_results = {}
    categories.pluck(:track_length).uniq.sort.each do |track_length|
      sorted_results[track_length] = race_results.joins(:category)
        .where(categories: {track_length: track_length})
        .sort_by {|rr| [
          rr.missed_control_points, -rr.lap_times.length, rr.finish_time
        ]}
    end
    sorted_results
  end

  def displayable_description
    Nokogiri(self.description_text.to_s).text
  end

  private

    def set_auth_token
      self.auth_token = SecureRandom.hex(3) if self.auth_token.blank?
    end
end
