class GenresController < ApplicationController
  def genres_select
    render json: Genre.all.as_json(only: %i[id name]), status: :ok
  end
end
