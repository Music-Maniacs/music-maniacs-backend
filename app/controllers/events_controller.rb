class EventsController < ApplicationController
  SHOW_EVENT_TO_JSON = { include: { image: { methods: %i[url] },
                                    links: { only: %i[id url title] },
                                    artist: { only: %i[id name] },
                                    producer: { only: %i[id name] },
                                    venue: { only: %i[id name] } },
                         methods: %i[versions reviews_info] }.freeze

  SEARCH_EVENT_TO_JSON = { only: %i[id name datetime description],
                           include:
                           { image: { methods: %i[url] },
                             artist: { only: :name },
                             producer: { only: :name },
                             venue: { only: :name } } }.freeze

  EVENT_TO_JSON = { include: { image: { methods: %i[url] },
                               links: { only: %i[id url title] },
                               artist: { only: %i[id name] },
                               producer: { only: %i[id name] },
                               venue: { only: %i[id name] } } }.freeze

  def show
    event = Event.find(params[:id])
    render json: event.as_json(SHOW_EVENT_TO_JSON), status: :ok
  end

  def search
    events = Event.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])

    render json: { data: events.as_json(SEARCH_EVENT_TO_JSON), pagination: pagination_info(events) }
  end

  def create
    event = Event.new(event_params)

    event.image = Image.new(file: params[:image]) if params[:image].present?

    if event.save
      render json: event.as_json(EVENT_TO_JSON), status: :ok
    else
      render json: { errors: event.errors.details }, status: :unprocessable_entity
    end
  end

  def update
    event = Event.find(params[:id])

    if params[:image].present?
      if event.image.present?
        event.image.file.purge
        event.image.file.attach(params[:image])
      else
        event.image = Image.new(file: params[:image])
      end
    end

    if event.update(event_edit_params)
      render json: event.as_json(EVENT_TO_JSON), status: :ok
    else
      render json: { errors: event.errors.details }, status: :unprocessable_entity
    end
  end

  private

  def event_params
    JSON.parse(params.require(:event)).deep_symbolize_keys.slice(:name,
                                                                 :description,
                                                                 :datetime,
                                                                 :artist_id,
                                                                 :producer_id,
                                                                 :venue_id,
                                                                 :links_attributes)
  end

  def event_edit_params
    JSON.parse(params.require(:event)).deep_symbolize_keys.slice(:name,
                                                                 :description,
                                                                 :datetime,
                                                                 :links_attributes)
  end
end
