class ArtistsController < ApplicationController
  include FollowableActions

  ARTIST_TO_JSON = { include: { genres: { only: %i[id name] },
                                links: { only: %i[id url title] },
                                image: { methods: %i[full_url] },
                                last_reviews: { only: %i[id rating description] } },
                     methods: %i[versions rating past_events next_events] }.freeze

  def show
    artist = Artist.find(params[:id])

    render json: artist.as_json(ARTIST_TO_JSON)
  end

  def create
    artist = Artist.new(artist_params)

    artist.image = Image.new(file: params[:image]) if params[:image].present?

    if artist.save
      render json: artist.as_json(ARTIST_TO_JSON), status: :ok
    else
      render json: { errors: artist.errors.details }, status: :unprocessable_entity
    end
  end

  def update
    artist = Artist.find(params[:id])

    if params[:image].present?
      if artist.image.present?
        artist.image.file.purge
        artist.image.file.attach(params[:image])
      else
        artist.image = Image.new(file: params[:image])
      end
    end

    if artist.update(artist_params)
      render json: artist.as_json(ARTIST_TO_JSON), status: :ok
    else
      render json: { errors: artist.errors.details }, status: :unprocessable_entity
    end
  end

  private

  def artist_params
    JSON.parse(params.require(:artist)).deep_symbolize_keys.slice(:name,
                                                                  :description,
                                                                  :nationality,
                                                                  :links_attributes,
                                                                  :genre_ids)
  end
end
