# frozen_string_literal: true

class ProcessEventJob < ApplicationJob
  queue_as :default

  def initialize(*args)
    super(*args)
    @rules = Rule.set_from_definitions
  end

  def perform(event)
    @rules.each do |rule|
      if rule.matches?(event)
        EventNotificationMailer.notice(rule.recipients, rule.subject, event).deliver_now
      end
    end
  end
end
