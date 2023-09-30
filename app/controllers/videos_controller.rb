class VideosController < ApplicationController
  before_action :authenticate_user!, only: %i[create destroy]
  include LikeableActions

  VIDEO_TO_SHOW = { only: %i[id name created_at recorded_at],
                    methods: %i[full_url anonymous likes_count],
                    include: { user: { only: %i[id username] } } }.freeze
  def create
    event = Event.find(params[:id])
    video = event.videos.build(video_params)

    video.file.attach(params[:video]) # Asigna el archivo cargado a la instancia de Video
    video.user = current_user

    if video.save
      render json: video.as_json(VIDEO_TO_SHOW), status: :ok
    else
      render json: { errors: video.errors.details }, status: :unprocessable_entity
    end
  end

  def destroy
    video = Video.find(params[:id])

    if video.destroy
      head :no_content, status: :ok
    else
      render json: { errors: video.errors.details }, status: :unprocessable_entity
    end
  end

  def show
    videos = Event.find(params[:id]).videos.reorder(params[:sort] || 'recorded_at asc')

    render json: videos.as_json(VIDEO_TO_SHOW), status: :ok
  end

  private

  def video_params
    params.permit(:recorded_at, :name)
  end
end
