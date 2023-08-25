class Admin::LocationsController < ApplicationController
    
    def index
        locations = Location.all
            render status:200 ,json: {locations: locations}
    end
    
    def show
        location = Location.find_by(id: params[:id])
        
        if location.present?
          render status: 200, json: { location: location }
        else
          render status: 404, json: { message: "No se encuentra la ubicacion"}
        end
    end


    def create
        location  = Location.create(location_params)
        
        if location.persisted?
            render status:200 ,json: {location: location}
        else
            render status:400, json: {message: location.errors.details}
        end
    end

    def update
        location = Location.find_by(id: params[:id])
        
        if location.present?
          if location.update(location_params)
            render status: 200, json: { location: location }
          else
            render status: 400, json: { message: location.errors.details }
          end
        else
          render status: 404, json: { message: "No se encuentra la ubicacion #{params[:id]}" }
        end
    end

    def destroy 
      location = Location.find_by(id: params[:id])
      if location.present?
        if location.destroy
          render status: 200
        else
          render status: 400, json: { message: location.errors.details }
        end
      else
        render status: 404, json: { message: "No se encuentra la ubicacion #{params[:id]}" }
      end
    end 

    private

    def location_params
      params.require(:location).permit(:zip_code,
          :street,
          :department,
          :locality,
          :latitude,
          :longitude,
          :number,
          :country,
          :province)
    end
end
