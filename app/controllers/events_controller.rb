class EventsController < ApplicationController
  def index
    ProcessEventJob.perform_later(event)
    render json: { status: :ok }
  end

  def event
    # Using request.POST, because `action` is overridden in the `params` with the action name (in this case, index)
    request
      .POST
      .slice(
        :actor_type,
        :actor_id,
        :action,
        :object_type,
        :object_id,
        :success,
        :code,
        :message,
        :created_at)
      .tap {|e| e[:references] = request.POST[:references]}
  end
end
