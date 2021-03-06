# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Rule do
  describe '.set_from_definitions' do
    it 'instantiates rule objects from the config rules.yml' do
      rules = Rule.set_from_definitions
      expect(rules.first).to be_a Rule
      expect(rules.first.subject).to eql('unsuccessful unlock attempt!')
      expect(rules.first.recipients).to eql(%w[test@example.com another@example.com])
      expect(rules.first.matches?(success: 'false', action: 'unlock')).to be_truthy
    end
  end

  describe '#matches' do
    let(:time) { nil }
    let(:user) { nil }
    let(:action) { nil }
    let(:object) { nil }
    let(:success) { nil }
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
        created_at: '2017-11-11T20:01:00+01:00'
      }
    end

    subject { described_class.new('', [''], conditions) }

    context 'empty conditions set' do
      it 'matches any event' do
        expect(subject.matches?(event)).to be_truthy
      end
    end

    context 'user condition is the same as event' do
      let(:user) { 'email@example.com' }
      it 'matches' do
        expect(subject.matches?(event)).to be_truthy
      end
    end

    context 'user condition is different from event' do
      let(:user) { 'not_email@example.com' }
      it 'does not match' do
        expect(subject.matches?(event)).to be_falsey
      end
    end

    context 'action condition is the same as event' do
      let(:action) { 'unlock' }
      it 'matches' do
        expect(subject.matches?(event)).to be_truthy
      end
    end

    context 'action condition is different from event' do
      let(:action) { 'lock' }
      it 'does not match' do
        expect(subject.matches?(event)).to be_falsey
      end
    end

    context 'object condition is the same as event' do
      let(:object) { 'Lock' }
      it 'matches' do
        expect(subject.matches?(event)).to be_truthy
      end
    end

    context 'object condition is different from event' do
      let(:object) { 'Door' }
      it 'does not match' do
        expect(subject.matches?(event)).to be_falsey
      end
    end

    context 'success condition is the same as event' do
      let(:success) { 'true' }
      it 'matches' do
        expect(subject.matches?(event)).to be_truthy
      end
    end

    context 'success condition is different from event' do
      let(:success) { 'false' }
      it 'does not match' do
        expect(subject.matches?(event)).to be_falsey
      end
    end

    context 'success condition is set as any' do
      let(:success) { 'any' }
      it 'does not match' do
        expect(subject.matches?(event)).to be_truthy
      end
    end

    context 'time condition' do
      let(:time_begin) { nil }
      let(:time_end) { nil }
      let(:time) do
        { begin: time_begin, end: time_end }
      end

      context 'set empty' do
        it 'matches' do
          expect(subject.matches?(event)).to be_truthy
        end
      end

      context 'set only with begin' do
        let(:time_begin) { '00:00' }
        it 'matches' do
          expect(subject.matches?(event)).to be_truthy
        end
      end

      context 'set only with end' do
        let(:time_end) { '00:00' }
        it 'matches' do
          expect(subject.matches?(event)).to be_truthy
        end
      end

      context 'set between the same day,' do
        context 'and event time is not in between (UTC)' do
          let(:time_begin) { '20:01' }
          let(:time_end) { '20:02' }
          it 'matches' do
            expect(subject.matches?(event)).to be_falsey
          end
        end

        context 'and event time is in between' do
          let(:time_begin) { '19:01' }
          let(:time_end) { '19:02' }
          it 'matches' do
            expect(subject.matches?(event)).to be_truthy
          end
        end

        context 'and event time is not in between' do
          let(:time_begin) { '19:01' }
          let(:time_end) { '19:01' }
          it 'matches' do
            expect(subject.matches?(event)).to be_falsey
          end
        end
      end

      context 'set between two days' do
        context 'and event time is in between, and in the first day' do
          let(:time_begin) { '19:00' }
          let(:time_end) { '18:59' }
          it 'matches' do
            expect(subject.matches?(event)).to be_truthy
          end
        end

        context 'and event time is in between, and in the second day' do
          let(:time_begin) { '19:04' }
          let(:time_end) { '19:02' }
          it 'matches' do
            expect(subject.matches?(event)).to be_truthy
          end
        end

        context 'and event time is not in between' do
          let(:time_begin) { '19:02' }
          let(:time_end) { '19:01' }
          it 'matches' do
            expect(subject.matches?(event)).to be_falsey
          end
        end
      end
    end
  end
end
