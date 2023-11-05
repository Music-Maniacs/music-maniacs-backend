class Admin::EventsController < ApplicationController
  def self.public_endpoints
    %i[search_typeahead]
  end

  before_action :authenticate_user!, except: public_endpoints
  before_action :authorize_action, except: public_endpoints

  EVENT_TO_JSON = { include: { image: { methods: %i[full_url] },
                               links: { only: %i[id url title] },
                               artist: { only: %i[id name] },
                               producer: { only: %i[id name] },
                               venue: { only: %i[id name] } } }.freeze

  SHOW_EVENT_TO_JSON = { include: { image: { methods: %i[full_url] },
                                    links: { only: %i[id url title] },
                                    artist: { only: %i[id name] },
                                    producer: { only: %i[id name] },
                                    venue: { only: %i[id name] },
                                    versions: { except: :object_changes, methods: %i[named_object_changes anonymous], include: { user: { only: %i[id full_name] } } } },
                         methods: %i[reviews_info] }.freeze

  def index
    events = Event.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])

    render json: { data: events.as_json(EVENT_TO_JSON), pagination: pagination_info(events) }
  end

  def show
    event = Event.find(params[:id])

    render json: event.as_json(SHOW_EVENT_TO_JSON)
  end

  def create
    event = Event.new(event_params)

    event.image = Image.new(file: params[:image]) if params[:image].present?

    if event.save
      render json: event.as_json(SHOW_EVENT_TO_JSON), status: :ok
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

    if event.update(event_params)
      render json: event.as_json(SHOW_EVENT_TO_JSON), status: :ok
    else
      render json: { errors: event.errors.details }, status: :unprocessable_entity
    end
  end

  def destroy
    event = Event.find(params[:id])

    if event.destroy
      head :no_content, status: :ok
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
end
