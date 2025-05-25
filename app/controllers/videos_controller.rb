class VideosController < ApplicationController
  include LikeableActions
  include ReportableActions

  def self.public_endpoints
    %i[show like remove_like destroy]
  end

  before_action :authenticate_user!, except: %i[show]
  before_action :authorize_action, except: public_endpoints

  VIDEO_TO_SHOW = { only: %i[id name created_at recorded_at],
                    methods: %i[full_url anonymous likes_count liked_by_current_user],
                    include: { user: { only: %i[id username] } } }.freeze
  def create
    event = Event.find(params[:id])
    video = event.videos.build(video_params)
    video.user = current_user

    signed_id = params[:signed_id]

    # Find the blob by signed_id
    blob = ActiveStorage::Blob.find_signed(signed_id)
    video.file.attach(blob)

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

    render json: videos_json
  end

  private

  def video_params
    params.permit(:recorded_at, :name)
  end
end
