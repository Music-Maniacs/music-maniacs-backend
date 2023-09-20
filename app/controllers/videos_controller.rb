class VideosController < ApplicationController
  before_action :authenticate_user!, only: %i[create destroy]
  VIDEO_TO_SHOW = { only: %i[id created_at recorded_at],
                    methods: %i[full_url],
                    include:
                      { user:
                        { only: %i[id username] } } }.freeze
  VIDEO_TO_JSON = { methods: %i[full_url] }.freeze

  def create
    event = Event.find(params[:id])
    video = Video.new

    video.file.attach(params[:video]) # Asigna el archivo cargado a la instancia de Video
    video.recorded_at = params[:recorded_at] if params[:recorded_at].present?
    video.user = current_user
    event.videos << video

    if video.save
      render json: video.as_json(VIDEO_TO_JSON), status: :ok
    else
      render json: { errors: video.errors.details }, status: :unprocessable_entity
    end
  end

  def destroy
    video = Video.find(params[:video_id])

    if video.destroy && video.event.videos.delete(video)
      head :no_content, status: :ok
    else
      render json: { errors: video.errors.details }, status: :unprocessable_entity
    end
  end

  def show
    event = Event.find(params[:id])

    if event.videos.present?
      videos = event.videos
      render json: videos.as_json(VIDEO_TO_SHOW), status: :ok
    else
      render head :no_content, status: :ok
    end
  end

  private

  def video_params
    params.require(:video)
  end
end