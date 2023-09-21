class ProfilesController < ApplicationController
  def search
    artists = Artist.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])
    producers = Producer.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])
    venues = Venue.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])

    render json: 
  end
end