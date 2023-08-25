class Admin::ArtistsController < ApplicationController
  def index
    artists = Artist.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])

    render json: { data: artists, pagination: pagination_info(artists) }
  end

  def show
    artist = Artist.find(params[:id])

    render json: artist.as_json(ARTIST_TO_JSON)
  end

  def create
    artist = Artist.new(artist_params)

    if artist.save
      render json: artist.as_json(ARTIST_TO_JSON), status: :ok
    else
      render json: { errors: artist.errors.details }, status: :unprocessable_entity
    end
  end

  def update
    artist = Artist.find(params[:id])

    if artist.update(artist_params)
      render json: artist.as_json(ARTIST_TO_JSON), status: :ok
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

  def upload_image
    artist = Artist.find(params[:id])

    if params[:image].present?
      if artist.image.present?
        artist.image.file.purge
        artist.image.file.attach(params[:image])
      else
        artist.image = Image.new(file: params[:image])
      end
    end

    if artist.save
      render json: artist.as_json(ARTIST_TO_JSON), status: :ok
    else
      render json: { errors: artist.errors.details }, status: :unprocessable_entity
    end
  end

  def delete_image
    artist = Artist.find(params[:id])

    if artist.image.destroy
      head :no_content, status: :ok
    else
      render json: { errors: artist.errors.details }, status: :unprocessable_entity
    end
  end

  private

  ARTIST_TO_JSON = { include: {
    genres: {
      only: %i[id name]
    },
    links: {
      only: %i[id url title]
    },
    image: {
      methods: %i[url]
    }
  } }

  def artist_params
    params.require(:artist).permit(:name, :description, :nationality, genre_ids: [],
                                                                      links_attributes: %i[url title _destroy id])
  end
end
