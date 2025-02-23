class Admin::VenuesController < ApplicationController
  include Search

  def self.public_endpoints
    %i[search_typeahead]
  end

  before_action :authenticate_user!, except: public_endpoints
  before_action :authorize_action, except: public_endpoints

  VENUE_TO_JSON = { include: { location: { only: %i[zip_code street city latitude longitude number country province] },
                               links: { only: %i[id url title] },
                               image: { methods: %i[full_url] } },
                    methods: [:address] }.freeze

  SHOW_VENUE_TO_JSON = { include: { location: { only: %i[zip_code street city latitude longitude number country province] },
                                    links: { only: %i[id url title] },
                                    image: { methods: %i[full_url] },
                                    history: { except: :object_changes, methods: %i[named_object_changes anonymous], include: { user: { only: %i[id full_name] } } } },
                         methods: %i[address] }.freeze

  def index
    venues = venues_scope.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])
    render json: { data: venues.as_json(VENUE_TO_JSON), pagination: pagination_info(venues) }
  end

  def show
    venue = venues_scope.find(params[:id])

    render json: venue.as_json(SHOW_VENUE_TO_JSON)
  end

  def create
    venue = Venue.new(venue_params)

    venue.image = Image.new(file: params[:image]) if params[:image].present?

    if venue.save
      venue.image.convert_to_webp if venue.image.present?

      render json: venue.as_json(SHOW_VENUE_TO_JSON), status: :ok
    else
      render json: { errors: venue.errors.details }, status: :unprocessable_entity
    end
  end

  def update
    venue = venues_scope.find(params[:id])

    if params[:image].present?
      if venue.image.present?
        venue.image.file.purge
        venue.image.file.attach(params[:image])
      else
        venue.image = Image.new(file: params[:image])
      end
    end

    if venue.update(venue_params)
      venue.image.convert_to_webp if venue.image.present?

      render json: venue.as_json(SHOW_VENUE_TO_JSON), status: :ok
    else
      render json: { errors: venue.errors.details }, status: :unprocessable_entity
    end
  end

  def destroy
    venue = venues_scope.find(params[:id])

    if venue.destroy
      render status: :ok
    else
      render json: { errors: venue.errors.details }, status: :unprocessable_entity
    end
  end

  private

  def venues_scope
    Venue.with_deleted
  end

  def venue_params
    JSON.parse(params.require(:venue)).deep_symbolize_keys.slice(:name, :description, :location_attributes, :links_attributes, :image_attributes)
  end
end
