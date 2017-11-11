class EventNotificationMailer < ApplicationMailer
  def notice(recipients, subject, event)
    @recipients = recipients
    @event = event
    mail(to: @recipients, subject: subject)
  end
end
