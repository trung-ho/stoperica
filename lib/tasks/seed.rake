require 'faker'

namespace :db do
  desc "Seeds racers"
  task seed_race: :environment do
    race = Race.create!(name: Faker::DcComics.villain, date: (DateTime.now + 1.day), registration_threshold: (DateTime.now + 1.day))
    category = Category.create!(name: Faker::DcComics.hero, race: race)
    (1..30).to_a.each do |index|
      name = Faker::DcComics.name
      racer = Racer.create!(
        first_name: name.split[0],
        last_name: name.split[1],
        phone_number: Faker::PhoneNumber.cell_phone,
        email: Faker::Internet.email
      )
      start_number = StartNumber.create!(value: index, race: race)
      RaceResult.create!(race: race, racer: racer, category: category, start_number: start_number)
    end
  end
end
