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

  describe '#matches' do
    let(:time) {nil}
    let(:user) {nil}
    let(:action) {nil}
    let(:object) {nil}
    let(:success) {nil}
    let(:conditions) do
      {
        time: time,
        user: user,
        action: action,
        object: object,
        success: success
      }
    end
    let(:event) do
      {
        actor_email: 'email@example.com',
        action: 'unlock',
        object_type: 'Lock',
        success: 'true',
        created_at: '2017-11-11T20:01:20+01:00'
      }
    end

    subject {described_class.new('', [''], conditions)}

    context 'empty conditions set' do
      it 'matches any event' do
        expect(subject.matches?(event)).to be_truthy
      end
    end

    context 'user condition is the same as event' do
      let(:user) {'email@example.com'}
      it 'matches' do
        expect(subject.matches?(event)).to be_truthy
      end
    end

    context 'user condition is different from event' do
      let(:user) {'not_email@example.com'}
      it 'does not match' do
        expect(subject.matches?(event)).to be_falsey
      end
    end
  end
end
