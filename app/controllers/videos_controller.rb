class VideosController < ApplicationController
  def create
    event = Event.find(params[:id])
    video = Video.new # Crear una nueva instancia de Video

    video.file.attach(params[:video]) # Asignar el archivo cargado a la instancia de Video
    event.videos << video

    if video.save
      render json: video, status: :ok
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

  private

  def video_params
    params.require(:video)
  end
end