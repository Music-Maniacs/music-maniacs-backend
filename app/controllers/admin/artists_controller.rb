class Admin::ArtistsController < ApplicationController
  include Search
  ARTIST_TO_JSON = { include: { genres: { only: %i[id name] },
                                links: { only: %i[id url title] },
                                image: { methods: %i[full_url] } } }.freeze

  SHOW_ARTIST_TO_JSON = { include: { genres: { only: %i[id name] },
                                     links: { only: %i[id url title] },
                                     image: { methods: %i[full_url] },
                                     versions: { except: :object_changes, methods: %i[anonymous named_object_changes], include: { user: { only: %i[id full_name] } } } } }.freeze

  def index
    artists = Artist.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])

    render json: { data: artists.as_json(ARTIST_TO_JSON), pagination: pagination_info(artists) }
  end

  def show
    artist = Artist.find(params[:id])

    render json: artist.as_json(SHOW_ARTIST_TO_JSON)
  end

  def create
    artist = Artist.new(artist_params)

    artist.image = Image.new(file: params[:image]) if params[:image].present?

    if artist.save
      artist.image.convert_to_webp

      render json: artist.as_json(SHOW_ARTIST_TO_JSON), status: :ok
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

      render json: artist.as_json(SHOW_ARTIST_TO_JSON), status: :ok
    else
      render json: { errors: artist.errors.details }, status: :unprocessable_entity
    end
  end

  def destroy
    artist = Artist.find(params[:id])

    if artist.destroy
      head :no_content, status: :ok
    else
      render json: { errors: artist.errors.details }, status: :unprocessable_entity
    end
  end

  private

  def artist_params
    JSON.parse(params.require(:artist)).deep_symbolize_keys.slice(:name, :description, :nationality, :links_attributes, :genre_ids)
  end
end
