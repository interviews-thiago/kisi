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
    recipients = %w(a@example.com)
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
  # ❏ Time:   include   time   ranges   during   which   the   rule   should   be   matched
  # ❏ User:   include   emails   that   should   match   (the   event   has   an   actor   email   field) ❏ Action:   which   action   should   match,   e.g.   unlock
  # ❏ Object:   which   object   type   should   match,   e.g.   Lock
  # ❏ Success:   filter   only   successful   or   unsuccessful   events   (or   both)

  #   Demonstrate your microservice by filtering out unsuccessful unlock attempts and send an email to   the   subscribed   users   informing   them   that   an   unlock   failed
end
