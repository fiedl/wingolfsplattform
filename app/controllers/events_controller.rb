require_dependency YourPlatform::Engine.root.join('app/controllers/events_controller').to_s

module EventsControllerModifications

  private

  def event_params
    params.fetch(:event, {}).permit(*(super.keys + [:aktive, :philister]))
  end

end

class EventsController
  prepend EventsControllerModifications
end
