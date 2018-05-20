class RacerMailer < ApplicationMailer
  default from: 'Stoperica Timing <stoperica.timing@gmail.com>'

  def race_details(racer, subject, body)
    @racer = racer
    mail(
      to: @racer.email,
      subject: subject,
      body: body,
      content_type: 'text/html'
    )
  end
end
