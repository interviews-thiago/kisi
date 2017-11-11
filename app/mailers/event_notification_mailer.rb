class EventNotificationMailer < ApplicationMailer
  def notice(recipients, subject, event)
    @subject = subject
    @event = event
    mail(to: recipients, subject: subject)
  end
end
