class Racer < ApplicationRecord
  
  belongs_to :user, dependent: :delete, optional: true
  belongs_to :club, optional: true
  
  has_many :race_results, dependent: :destroy
  has_many :races, through: :race_results

  validates :email, presence: true, uniqueness: true
  validates :phone_number, presence: true, uniqueness: true
  validates :uci_id, format: /[0-9\s]{11,14}/, if: Proc.new { |racer| racer.is_biker == '1' }

  attr_accessor :personal_best_hours, :personal_best_minutes, :personal_best_seconds
  attr_writer :is_biker

  before_save :set_uci_id, :set_personal_best, :set_club

  scope :club_admins, -> { where(club_admin: true) }

  paginates_per 80

  def full_name
    "#{first_name} #{last_name}"
  end

  def uci_name
    "#{last_name.mb_chars.upcase} #{first_name}"
  end

  def club_name is_uci = false
    if is_uci && uci_id === 'Jednodnevna'
      'Individual'
    else
      club.try(:name)
    end
  end

  def country_flag
    if country.present?
      Country.new(country).emoji_flag
    else
      ''
    end
  end

  def country_name
    if country.present?
      Country.new(country).name
    else
      ''
    end
  end

  def birth_date
    "#{year_of_birth}-#{month_of_birth}-#{day_of_birth}"
  end

  def full_address
    "#{address} #{zip_code} #{town} #{country_name}"
  end

  def is_biker
    return @is_biker if @is_biker

    if !self.uci_id || self.uci_id == 'Jednodnevna'
      '0'
    else
      '1'
    end
  end

  def is_biker?
    self.is_biker == '1'
  end

  private

    def individual_club_id
      Club.where(name: 'Individual').first&.id
    end

    def set_uci_id
      if self.is_biker == '0'
        self.uci_id = 'Jednodnevna'
      else
        self.uci_id = uci_id.gsub(' ', '')
      end
    end

    def set_personal_best
      # Minutes and seconds are enough...
      if !self.personal_best_minutes.blank? && !self.personal_best_seconds.blank?
        self.personal_best = "#{self.personal_best_hours}:#{self.personal_best_minutes}:#{self.personal_best_seconds}"
      end
    end

    # Instead of naming racers (who doesn't have a club_id) an Individual...
    # the genius has a club entry named 'Individual'. :facepalm:
    # So now if a racer doesn't select a club on signup we assign him to the 'Individual' club. Yay!
    def set_club
      self.club_id = individual_club_id if self.club_id.blank?
    end
end
