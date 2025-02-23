class VenuesController < ApplicationController
  include FollowableActions
  include ReviewableActions
  include ReportableActions

  def self.public_endpoints
    %i[show reviews follow unfollow]
  end

  before_action :authenticate_user!, except: %i[show reviews]
  before_action :authorize_action, except: %i[show reviews follow unfollow]

  VENUE_TO_JSON = { include: { location: { only: %i[zip_code street city latitude longitude number country province] },
                               links: { only: %i[id url title] },
                               image: { methods: %i[full_url] },
                               last_reviews: { only: %i[id rating description created_at reviewable_type],
                                               include: { user: { only: %i[id full_name], methods: :profile_image_full_url } },
                                               methods: :anonymous },
                               history: { except: :object_changes, methods: %i[named_object_changes anonymous], include: { user: { only: %i[id full_name], methods: :profile_image_full_url } } } },
                    methods: %i[rating past_events next_events address] }.freeze

  def show
    venue = Venue.find(params[:id])
    venue_json = venue.as_json(VENUE_TO_JSON)

    venue_json['followed_by_current_user'] = if current_user.present?
                                                current_user.follows?(venue)
                                              else
                                                false
                                              end
    render json: venue_json, status: :ok
  end

  def create
    venue = Venue.new(venue_params)

    venue.image = Image.new(file: params[:image]) if params[:image].present?

    if venue.save
      venue.image.convert_to_webp if venue.image.present?

      render json: venue.as_json(VENUE_TO_JSON), status: :ok
    else
      render json: { errors: venue.errors.details }, status: :unprocessable_entity
    end
  end

  def update
    venue = Venue.find(params[:id])

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

      render json: venue.as_json(VENUE_TO_JSON), status: :ok
    else
      render json: { errors: venue.errors.details }, status: :unprocessable_entity
    end
  end

  private

  def venue_params
    JSON.parse(params.require(:venue)).deep_symbolize_keys.slice(:name,
                                                                 :description,
                                                                 :location_attributes,
                                                                 :links_attributes,
                                                                 :image_attributes)
  end
end
