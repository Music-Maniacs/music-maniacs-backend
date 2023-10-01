class VideosController < ApplicationController
  before_action :authenticate_user!, only: %i[create destroy]
  include LikeableActions

  VIDEO_TO_SHOW = { only: %i[id name created_at recorded_at],
                    methods: %i[full_url anonymous likes_count liked_by_current_user],
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
    video = current_user.videos.find(params[:id])

    if video.destroy
      head :no_content, status: :ok
    else
      render json: { errors: video.errors.details }, status: :unprocessable_entity
    end
  end

  def show
    videos = Event.find(params[:id]).videos.reorder(params[:sort] || 'recorded_at asc')
    videos_json = if current_user.present?
                    videos.with_liked_by_user(current_user).as_json(VIDEO_TO_SHOW)
                  else
                    videos.as_json(VIDEO_TO_SHOW)
                  end

    render json: { data: videos_json, pagination: pagination_info(videos) }
  end

  private

  def video_params
    params.permit(:recorded_at, :name)
  end
end
