# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Rule do
  describe '.set_from_definitions' do
    it 'instantiates rule objects from the config rules.yml' do
      rules = Rule.set_from_definitions
      expect(rules.first).to be_a Rule
      expect(rules.first.subject).to eql('unsuccessful unlock attempt!')
      expect(rules.first.recipients).to eql(%w[test@example.com another@example.com])
      expect(rules.first.matches?(success: false, action: 'unlock')).to be_truthy
    end
  end
end
