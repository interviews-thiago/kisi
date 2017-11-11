# frozen_string_literal: true

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
      created_at: '',
      references: [
        { type: 'Place', id: 1 },
        { type: 'Lock', id: 1 }
      ]
    }
  end

  before { ActiveJob::Base.queue_adapter = :test }
  it 'returns ok' do
    headers = { Accept: 'application/json' }
    post '/events', params: lock_event, headers: headers
    expect(response.body).to eql({ status: :ok }.to_json)
  end

  it 'enqueue a job to process the event' do
    headers = { Accept: 'application/json', 'Content-Type': 'application/json' }
    post '/events', params: lock_event.to_json, headers: headers
    expect do
      post '/events', params: lock_event.to_json, headers: headers
    end.to have_enqueued_job(ProcessEventJob).with(lock_event)
  end

  it 'filters the fields passed to the Job to prevent "param injection"' do
    headers = { Accept: 'application/json', 'Content-Type': 'application/json' }
    extra_params = lock_event.dup
    extra_params[:foo] = 'bar'
    expect do
      post '/events', params: extra_params.to_json, headers: headers
    end.to have_enqueued_job(ProcessEventJob).with(lock_event)
  end
end
