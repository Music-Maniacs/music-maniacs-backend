class ProfilesController < ApplicationController
  def search
    artists = Artist.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])
    producers = Producer.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])
    venues = Venue.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])

    render json: { artists: { data: artists, pagination: pagination_info(artists) },
                   producers: { data: producers, pagination: pagination_info(producers) },
                   venues: { data: venues, pagination: pagination_info(venues) } }
  end

  def search_artists
    artists = Artist.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])
    render json: { data: artists, pagination: pagination_info(artists) }
  end

  def search_producers
    producers = Producer.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])
    render json: { data: producers, pagination: pagination_info(producers) }
  end

  def search_venues
    venues = Venue.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])
    render json: { data: venues, pagination: pagination_info(venues) }
  end
end
