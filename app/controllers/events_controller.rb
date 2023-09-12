class EventsController < ApplicationController
  before_action :set_default_url_options, only: [:create]
  include FollowableActions
  require 'streamio-ffmpeg'
  SHOW_EVENT_TO_JSON = { include: { image: { methods: %i[url] },
                                    links: { only: %i[id url title] },
                                    artist: { only: %i[id name] },
                                    producer: { only: %i[id name] },
                                    venue: { only: %i[id name] } },
                         methods: %i[versions reviews_info] }.freeze

  SEARCH_EVENT_TO_JSON = { only: %i[id name datetime description],
                           include: {
                             image: { methods: %i[url] },
                             artist: { only: :name },
                             producer: { only: :name },
                             venue: { only: :name } } }.freeze

  EVENT_TO_JSON = { include: { image: { methods: %i[url] },
                               links: { only: %i[id url title] },
                               videos: { methods: %i[url] },
                               artist: { only: %i[id name] },
                               producer: { only: %i[id name] },
                               venue: { only: %i[id name] } } }.freeze

  def show
    event = Event.find(params[:id])
    render json: event.as_json(SHOW_EVENT_TO_JSON), status: :ok
  end

  def search
    events = Event.ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])

    render json: { data: events.as_json(SEARCH_EVENT_TO_JSON), pagination: pagination_info(events) }
  end

  def create
    event = Event.new(event_params)

    event.image = Image.new(file: params[:image]) if params[:image].present?

    if event.save
      if params[:video].present?
        new_video = event.videos.new(file: params[:video])

        puts "ESTE ES EL URL DEL VIDEO: #{new_video.url}"

        if new_video.save
          date_assignment(new_video) # Asigna la fecha de grabación
          render json: event.as_json(EVENT_TO_JSON), status: :ok # Renderiza la respuesta JSON exitosa
        else
          # Manejo de errores si la creación del video falla
          render json: { errors: new_video.errors.details }, status: :unprocessable_entity
        end
      else
        render json: event.as_json(EVENT_TO_JSON), status: :ok # Renderiza la respuesta JSON exitosa sin video
      end
    else
      render json: { errors: event.errors.details }, status: :unprocessable_entity
    end
  end

  def update
    event = Event.find(params[:id])

    if params[:image].present?
      if event.image.present?
        event.image.file.purge
        event.image.file.attach(params[:image])
      else
        event.image = Image.new(file: params[:image])
      end
    end

    event.videos.new(file: params[:video]) if params[:video].present?

    if event.update(event_edit_params)
      render json: event.as_json(EVENT_TO_JSON), status: :ok
    else
      render json: { errors: event.errors.details }, status: :unprocessable_entity
    end
  end

  private

  def event_params
    JSON.parse(params.require(:event)).deep_symbolize_keys.slice(:name,
                                                                 :description,
                                                                 :datetime,
                                                                 :artist_id,
                                                                 :producer_id,
                                                                 :venue_id,
                                                                 :links_attributes,
                                                                 :videos_attributes)
  end

  def event_edit_params
    JSON.parse(params.require(:event)).deep_symbolize_keys.slice(:name,
                                                                 :description,
                                                                 :datetime,
                                                                 :links_attributes,
                                                                 :videos_attributes)
  end

  def date_assignment(video)
    # url = video.url
    url = Rails.application.routes.url_helpers.url_for(video.file)
    puts "ESTE ES EL URL DEL VIDEO dentro de date_assignment: #{url}"
    tempfile = Down.download(url) # Esto requiere la gema 'down'

    # Obtén la ruta del archivo temporal descargado
    tempfile_path = tempfile.path

    if video.file.attached?
      video_url = Rails.application.routes.url_helpers.rails_blob_url(video.file, only_path: true)
      movie = FFMPEG::Movie.new(video_url)

      if movie.valid?
        recorded_at = movie.creation_time
        video.update(recorded_at: recorded_at) if recorded_at.present?
      end
    end
    # Elimina el archivo temporal después de usarlo
    File.delete(tempfile_path) if File.exist?(tempfile_path)
  end

  def set_default_url_options
    Rails.application.routes.default_url_options[:host] = request.host_with_port
  end
end
