class Admin::ArtistsController < ApplicationController
  def index
    artists = Artist.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])

    render json: { data: artists, pagination: pagination_info(artists) }
  end

  def show
    artist = Artist.find(params[:id])

    render json: artist.as_json(include: {
                                  genres: {
                                    only: %i[id name]
                                  },
                                  links: {
                                    only: %i[id url title]
                                  }
                                })
  end

  def create
    artist = Artist.new(artist_params)

    if artist.save
      render json: artist.as_json(include: {
                                    genres: {
                                      only: %i[id name]
                                    },
                                    links: {
                                      only: %i[id url title]
                                    }
                                  }), status: :ok
    else
      render json: { errors: artist.errors.details }, status: :unprocessable_entity
    end
  end

  def update
    artist = Artist.find(params[:id])

    if artist.update(artist_params)
      render json: artist.as_json(include: {
                                    genres: {
                                      only: %i[id name]
                                    },
                                    links: {
                                      only: %i[id url title]
                                    }
                                  }), status: :ok
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
    params.require(:artist).permit(:name, :description, :nationality, genre_ids: [],
                                                                      links_attributes: %i[url title _destroy id])
  end
end
