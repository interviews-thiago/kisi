require 'rails_helper'

RSpec.describe 'POST /events', type: :request do
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
      references: [
        { type: 'Place', id: 1 },
        { type: 'Lock', id: 1 }
      ],
      created_at: ''
    }
  end

  it 'returns ok' do
    headers = { Accept: 'application/json' }
    post '/events', params: lock_event, headers: headers
    expect(response.body).to eql({status: :ok}.to_json)
  end
end
