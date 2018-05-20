class RacerMailer < ApplicationMailer
  default from: 'Stoperica Timing <stoperica.timing@gmail.com>'

  def race_details(racer, race)
    @racer = racer
    mail(
      to: @racer.email,
      subject: "Prijava na #{race.name}",
      body: race.email_body,
      content_type: 'text/html'
    )
  end
end
