# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessEventJob do
  let(:lock_event) do
    {
      actor_type: 'User',
      actor_id: 1,
      action: 'unlock',
      object_type: 'Lock',
      object_id: 1,
      success: 'true',
      code: 'ffffff',
      message: 'carl@kisi.io unlocked lock Entrance Door',
      created_at: '',
      references: [
        { type: 'Place', id: 1 },
        { type: 'Lock', id: 1 }
      ]
    }
  end

  it "when an event matches a rule, send email to it's recipients" do
    recipients = %w[a@example.com]
    email_subject = 'A Mocked Subject'
    rule_mock = double(Rule,
                       matches?: true,
                       recipients: recipients,
                       subject: email_subject)
    allow(Rule).to receive(:set_from_definitions).and_return([rule_mock])
    expect do
      subject.perform(lock_event)
    end.to change { ActionMailer::Base.deliveries.count }.by(1)
    email_sent = ActionMailer::Base.deliveries.last
    expect(email_sent.to).to eql recipients
    expect(email_sent.subject).to eql email_subject
  end
end
