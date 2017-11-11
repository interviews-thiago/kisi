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

  def matches?(_event)
    true
  end
end
