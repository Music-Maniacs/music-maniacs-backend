class VenuesController < ApplicationController
  #  before_action :authenticate_user!, only: [:user_info]
    
    def index
            @venues = Venue.all
            render status:200 ,json: {venues: @venues}
    end
    
    def show
        @venue = Venue.find_by(venue_id: params[:venue_identifier]) ||
        Venue.find_by(venue_name: params[:venue_identifier])
        
        if @venue.present?
          render status: 200, json: { venue: @venue }
        else
          render status: 404, json: { message: "No se encuentra el Espacio de eventos"}
        end
      end
      


    def create 

        venue  = Venue.create(venue_params)
        
        if venue.persisted?
            render status:200 ,json: {venue: venue}
        else 
            render status:400, json: {message: venue.errors.details}
        end
    end

    def update
        update_venue
    end

    private

    def venue_params
        params.permit(:venue_name,:description)
    end  

    def update_venue
        venue = Venue.find_by(venue_id: params[:venue_id])
        if venue.present?
            if venue.update(params.permit(:venue_name,:description))
                render status:200 ,json: {venue: venue}
            else 
                render status:400, json: {message: venue.errors.details}
            end
        else
            render status:404 , json: {message: "No se encuentra Espacio de eventos #{params[:id]}"}
        end
    end
end
