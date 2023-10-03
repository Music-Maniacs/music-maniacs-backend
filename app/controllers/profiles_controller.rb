class ProfilesController < ApplicationController
  def search
    artists = Artist.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])
    producers = Producer.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])
    venues = Venue.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])

    render json: { artists: { data: artists, pagination: pagination_info(artists) },
                   producers: { data: producers, pagination: pagination_info(producers) },
                   venues: { data: venues, pagination: pagination_info(venues) } }
  end

  %w[artists producers venues].each do |klass|
    define_method "search_#{klass}" do
      klass_results = klass.classify.constantize.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])
      render json: { data: klass_results, pagination: pagination_info(klass_results) }
    end
  end
end
