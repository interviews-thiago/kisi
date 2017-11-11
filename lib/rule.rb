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
    user_matches?(event) &&
      action_matches?(event) &&
      object_matches?(event) &&
      success_matches?(event) &&
      time_matches?(event)
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

  def success_matches?(event)
    !@conditions[:success] ||
      @conditions[:success] == 'any' ||
      @conditions[:success] == event[:success]
  end

  def time_matches?(event)
    time = @conditions[:time]
    !time || !time[:begin] || !time[:end] ||
      time_in_between(parse_created_at(event))
  end

  def time_in_between(event_time)
    beginning_condition, ending_condition = beginning_ending_time_conditions(event_time)
    beginning_condition <= event_time && event_time < ending_condition
  end

  def beginning_ending_time_conditions(event_time)
    beginning_hour_minute = @conditions[:time][:begin]
    ending_hour_minute = @conditions[:time][:end]
    if beginning_hour_minute <= ending_hour_minute
      beginning = Time.zone.parse(beginning_hour_minute, event_time)
      ending = Time.zone.parse(ending_hour_minute, event_time)
    else
      beginning = Time.zone.parse(beginning_hour_minute, event_time)
      if beginning <= event_time
        ending = Time.zone.parse(ending_hour_minute, event_time + 1.day)
      else
        beginning = Time.zone.parse(beginning_hour_minute, event_time - 1.day)
        ending = Time.zone.parse(ending_hour_minute, event_time)
      end
    end
    [beginning, ending]
  end

  def parse_created_at(event)
    Time.zone.parse(event[:created_at]).beginning_of_minute
  end
end
