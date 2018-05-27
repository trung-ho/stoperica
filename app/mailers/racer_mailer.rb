class RacerMailer < ApplicationMailer
  default from: 'Stoperica Timing <stoperica.timing@gmail.com>'

  def welcome(racer)
    @racer = racer
    mail(to: @racer.email, subject: 'Welcome to Stoperica.live')
  end

  def race_details(racer, race)
    mail(
      to: racer.email,
      subject: "Prijava na #{race.name}",
      body: race.email_body,
      content_type: 'text/html'
    )
  end
end
