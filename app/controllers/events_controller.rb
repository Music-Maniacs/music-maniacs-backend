class EventsController < ApplicationController
  SHOW_EVENT_TO_JSON = { include: { image: { methods: %i[url] },
                                    links: { only: %i[id url title] },
                                    artist: { only: %i[id name] },
                                    producer: { only: %i[id name] },
                                    venue: { only: %i[id name] } },
                         methods: %i[versions reviews_info] }.freeze

  SEARCH_EVENT_TO_JSON = { only: %i[id name datetime description],
                           include: {
                             image: { methods: %i[url] },
                             artist: { only: :name },
                             producer: { only: :name },
                             venue: { only: :nmae }
                           } }.freeze
  def show
    event = Event.find(params[:id])
    render json: event.as_json(SHOW_EVENT_TO_JSON), status: :ok
  end

  def search
    events = Event.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])

    render json: { data: events.as_json(SEARCH_EVENT_TO_JSON), pagination: pagination_info(events) }
  end
end
