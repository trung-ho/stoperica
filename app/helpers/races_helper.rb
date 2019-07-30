module RacesHelper

  def additional_information(race)
    if race.description_text? && race.description_url?
      link_to race.description_text, race.description_url, target: '_blank'
    elsif race.description_url?
      link_to "Dodatne informacije", race.description_url, target: '_blank'
    else
      race.description_text
    end
  end
end
