class EventsController < ApplicationController
  EVENT_TO_JSON = { include: { image: { methods: %i[url] },
                               links: { only: %i[id url title] },
                               artist: { only: %i[id name] },
                               producer: { only: %i[id name] },
                               venue: { only: %i[id name] } },
                    methods: %i[versions reviews_info] }.freeze

  def show
    event = Event.find(params[:id])
    render json: event.as_json(EVENT_TO_JSON), status: :ok
  end
end
