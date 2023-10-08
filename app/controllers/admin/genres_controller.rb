class Admin::GenresController < ApplicationController
  before_action :validate_user_is_admin

  def index
    genres = Genre.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])

    render json: { data: genres, pagination: pagination_info(genres) }
  end

  def create
    genre = Genre.new(genre_params)

    if genre.save
      render json: genre, status: :ok
    else
      render json: { errors: genre.errors.details }, status: :unprocessable_entity
    end
  end

  def update
    genre = Genre.find(params[:id])

    if genre.update(genre_params)
      render json: genre, status: :ok
    else
      render json: { errors: genre.errors.details }, status: :unprocessable_entity
    end
  end

  def destroy
    genre = Genre.find(params[:id])

    if genre.destroy
      head :no_content, status: :ok
    else
      render json: { errors: genre.errors.details }, status: :unprocessable_entity
    end
  end

  def genres_select
    render json: Genre.all.as_json(only: %i[id name]), status: :ok
  end

  private

  def genre_params
    params.require(:genre).permit(:name)
  end
end
