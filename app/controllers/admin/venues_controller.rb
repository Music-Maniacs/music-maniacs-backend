class Admin::VenuesController < ApplicationController
    
    def index
        venues = Venue.all
            render status:200 ,json: {venues: venues}
    end
    
    def show
        venue = Venue.find_by(id: params[:venue_identifier]) ||
        Venue.find_by(venue_name: params[:venue_identifier])
        
        if venue.present?
          render status: 200, json: { venue: venue }
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
        venue = Venue.find_by(id: params[:id])
        
        if venue.present?
          if venue.update(venue_params)
            render status: 200, json: { venue: venue }
          else
            render status: 400, json: { message: venue.errors.details }
          end
        else
          render status: 404, json: { message: "No se encuentra el Espacio de eventos #{params[:id]}" }
        end
    end

    def destroy 
      venue = Venue.find_by(id: params[:id])
      if venue.present?
        if venue.destroy
          render status: 200
        else
          render status: 400, json: { message: venue.errors.details }
        end
      else
        render status: 404, json: { message: "No se encuentra el Espacio de eventos #{params[:id]}" }
      end
    end 

    private

    def venue_params
        params.permit(:venue_name,:description)
    end
end
