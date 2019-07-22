class Racer < ApplicationRecord
  
  belongs_to :user, dependent: :delete, optional: true
  belongs_to :club, optional: true
  
  has_many :race_results, dependent: :destroy
  has_many :races, through: :race_results

  validates :email, presence: true, uniqueness: true
  validates :phone_number, presence: true, uniqueness: true
  validates :personal_best, format: /[0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}/, allow_nil: true, allow_blank: true
  validates :uci_id, format: /[0-9]{11}/, if: Proc.new { |racer| racer.is_biker == '1' }

  attr_accessor :is_biker

  before_save :set_uci_id

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

  private

    def set_uci_id
      self.uci_id = 'Jednodnevna' if self.is_biker == '0'
    end
end
