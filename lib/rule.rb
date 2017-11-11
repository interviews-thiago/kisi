# frozen_string_literal: true

class Rule
  def self.set_from_definitions
    definitions = YAML.safe_load(File.read(File.join(Rails.root, 'config', 'rules.yml')))
    definitions
      .map { |r| HashWithIndifferentAccess.new(r) }
      .map { |r| new(r[:subject], r[:recipients], r[:conditions]) }
  end

  attr_reader :subject, :recipients

  def initialize(subject, recipients, conditions)
    @subject = subject
    @recipients = recipients
    @conditions = conditions
  end

  def matches?(event)
    user_matches?(event) && action_matches?(event) && object_matches?(event)
  end

  private

  def user_matches?(event)
    !@conditions[:user] || @conditions[:user] == event[:actor_email]
  end

  def action_matches?(event)
    !@conditions[:action] || @conditions[:action] == event[:action]
  end

  def object_matches?(event)
    !@conditions[:object] || @conditions[:object] == event[:object_type]
  end
end
