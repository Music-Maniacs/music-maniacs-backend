class EventsController < ApplicationController
  before_action :authorize_action

  include FollowableActions

  SHOW_EVENT_TO_JSON = { include: { image: { methods: %i[full_url] },
                                    links: { only: %i[id url title] },
                                    artist: { only: %i[id name] },
                                    producer: { only: %i[id name] },
                                    venue: { only: %i[id name] },
                                    versions: { except: :object_changes, methods: %i[named_object_changes anonymous], include: { user: { only: %i[id full_name], methods: :profile_image_full_url  } } } },
                         methods: %i[reviews_info] }.freeze

  SEARCH_EVENT_TO_JSON = { only: %i[id name datetime description],
                           include:
                           { image: { methods: %i[full_url] },
                             artist: { only: :name },
                             producer: { only: :name },
                             venue: { only: :name } } }.freeze

  EVENT_TO_JSON = { include: { image: { methods: %i[full_url] },
                               links: { only: %i[id url title] },
                               artist: { only: %i[id name] },
                               producer: { only: %i[id name] },
                               venue: { only: %i[id name] } } }.freeze

  def show
    event = Event.find(params[:id])
    event.increase_visits_count!
    event_json = event.as_json(SHOW_EVENT_TO_JSON)

    current_user.user_stat.increment!(:viewed_events) if current_user.present?

    event_json['followed_by_current_user'] = if current_user.present?
                                               current_user.follows?(event)
                                             else
                                               false
                                             end
    render json: event_json, status: :ok
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
      render json: event.as_json(SHOW_EVENT_TO_JSON), status: :ok
    else
      render json: { errors: event.errors.details }, status: :unprocessable_entity
    end
  end

  def reviews
    event = Event.find(params[:id])
    reviews = event.reviews.where(reviewable_type: params[:reviewable_klass].capitalize)
                   .page(params[:page]).per(params[:per_page])

    render json: { data: reviews.as_json(Review::TO_JSON), pagination: pagination_info(reviews) }
  end

  def discover
    result = if current_user.present?
               { by_location: discover_order_limit_and_to_json(Event.discover_by_location(department: params[:department], province: params[:province], country: params[:country])),
                 most_popular: discover_order_limit_and_to_json(Event.most_popular),
                 by_followed_artists: discover_order_limit_and_to_json(Event.where(artist_id: current_user.followed_artists.pluck(:id)).order(created_at: :desc)),
                 by_followed_producers: discover_order_limit_and_to_json(Event.where(producer_id: current_user.followed_producers.pluck(:id)).order(created_at: :desc)),
                 by_followed_venues: discover_order_limit_and_to_json(Event.where(venue_id: current_user.followed_venues.pluck(:id)).order(created_at: :desc)) }
             else
               { by_location: discover_order_limit_and_to_json(Event.discover_by_location(department: params[:department], province: params[:province], country: params[:country])),
                 most_popular: discover_order_limit_and_to_json(Event.most_popular) }
             end
    render json: result, status: :ok
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

  def discover_order_limit_and_to_json(events)
    events.order(created_at: :desc).limit(10).as_json(EVENT_TO_JSON)
  end
end
