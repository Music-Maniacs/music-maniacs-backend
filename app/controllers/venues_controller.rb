class VenuesController < ApplicationController
  VENUE_TO_JSON = { include: { location: { only: %i[zip_code street department locality latitude longitude number country province] },
                               links: { only: %i[id url title] },
                               image: { methods: %i[url] },
                               last_reviews: { only: %i[id rating description] } },
                    methods: %i[versions rating past_events next_events] }.freeze

  def show
    venue = Venue.find(params[:id])

    render json: { venue: venue.as_json(VENUE_TO_JSON) }
  end

  def create
    venue = Venue.new(venue_params)

    venue.image = Image.new(file: params[:image]) if params[:image].present?

    if venue.save
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
