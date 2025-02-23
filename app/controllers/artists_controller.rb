class ArtistsController < ApplicationController
  include FollowableActions
  include ReviewableActions
  include ReportableActions

  def self.public_endpoints
    %i[show reviews follow unfollow]
  end

  before_action :authenticate_user!, except: public_endpoints
  before_action :authorize_action, except: public_endpoints

  ARTIST_TO_JSON = { include: { genres: { only: %i[id name] },
                                links: { only: %i[id url title] },
                                image: { methods: %i[full_url] },
                                last_reviews: { only: %i[id rating description created_at reviewable_type],
                                                include: { user: { only: %i[id full_name], methods: :profile_image_full_url  } },
                                                methods: :anonymous },
                                history: { except: :object_changes, methods: %i[anonymous named_object_changes], include: { user: { only: %i[id full_name], methods: :profile_image_full_url  } } } },
                     methods: %i[rating past_events next_events] }.freeze

  def show
    artist = Artist.find(params[:id])
    artist_json = artist.as_json(ARTIST_TO_JSON)

    artist_json['followed_by_current_user'] = if current_user.present?
                                                current_user.follows?(artist)
                                              else
                                                false
                                              end
    render json: artist_json, status: :ok
  end

  def create
    artist = Artist.new(artist_params)

    artist.image = Image.new(file: params[:image]) if params[:image].present?

    if artist.save
      artist.image.convert_to_webp if artist.image.present?

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
      artist.image.convert_to_webp if artist.image.present?

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
