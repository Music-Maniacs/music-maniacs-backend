class Admin::VenuesController < ApplicationController
  def index
    venues = Venue.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])
    render json: { data: venues.as_json(include: %i[links location]), pagination: pagination_info(venues) }
  end

  def show
    venue = Venue.find(id: params[:venue_identifier]) ||
            Venue.find(name: params[:venue_identifier])

    render json: venue.as_json(include: %i[links location])
  end

  def create
    venue = Venue.new(venue_params)

    if venue.save
      render json: venue.as_json(include: %i[links location]), status: :ok
    else
      render json: { errors: venue.errors.details }, status: :unprocessable_entity
    end
  end

  def update
    venue = Venue.find(params[:id])

    if venue.update(venue_params)
      render json: venue.as_json(include: %i[links location]), status: :ok
    else
      render json: { errors: venue.errors.details }, status: :unprocessable_entity
    end
  end

  def destroy
    venue = Venue.find(params[:id])

    if venue.destroy
      render status: :ok
    else
      render json: { errors: venue.errors.details }, status: :unprocessable_entity
    end
  end

  private

  def venue_params
    params.require(:venue).permit(:name, :description,
                                  location_attributes: %i[zip_code street department locality latitude longitude number country province _destroy],
                                  links_attributes: %i[url title _destroy id])
  end
end
