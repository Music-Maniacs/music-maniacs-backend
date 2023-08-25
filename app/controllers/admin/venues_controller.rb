class Admin::VenuesController < ApplicationController
    
    def index
        venues = Venue.all
            render status:200 ,json: {venues: venues}
    end
    
    def show
        venue = Venue.find_by(id: params[:venue_identifier]) ||
        Venue.find_by(venue_name: params[:venue_identifier])
        
        if venue.present?
          render status: 200, json: venue.as_json(include: :links)
        else
          render status: 404, json: { message: "No se encuentra el Espacio de eventos"}
        end
    end


    def create
      venue = Venue.new(venue_params)
    
      if venue.save
            render status:200 ,json: venue.as_json(include: :links)
        else
            render status:400, json: {message: venue.errors.details}
        end
    end

    def update
        venue = Venue.find(params[:id])
        
        if venue.present?
          if venue.update(venue_params)
            render status: 200, json: venue.as_json(include: :links)
          else
            render status: 400, json: { message: venue.errors.details }
          end
        else
          render status: 404, json: { message: "No se encuentra el Espacio de eventos #{params[:id]}" }
        end
    end

    def destroy
      venue = Venue.find(params[:id])
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
      params.require(:venue).permit(:venue_name,:description,
          location_attributes:
          [:zip_code, :street, :department, :locality, :latitude, :longitude, :number, :country, :province],
          links_attributes: [:url, :title, :_destroy, :id]
        )
    end
end
