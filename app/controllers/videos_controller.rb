class VideosController < ApplicationController
  def create
    event = Event.find(params[:id])
    video = Video.new # Crear una nueva instancia de Video

    video.file.attach(params[:video]) # Asignar el archivo cargado a la instancia de Video
    event.videos << video
    recorded_at_assignment(video)
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

  def recorded_at_assignment(video)
    attached_file = video.file # Obtener una representación del archivo adjunto

    if attached_file.present? # Asegurarse de que el archivo adjunto esté presente
      # Crear un archivo temporal con extensión .mp4
      tempfile = Tempfile.new(["tempfile", ".mp4"])

      # Abrir el archivo adjunto y copiar su contenido en el archivo temporal
      File.open(tempfile.path, "wb") do |file|
        file.write(attached_file.download)
      end

      exif = MiniExiftool.new(tempfile.path)  # Crea una instancia de MiniExiftool para el archivo de video

      # Intentar obtener la fecha de grabación del campo "File Modification"
      date_recorded = exif["CreateDate"] # FileModifyDate || CreateDate || ModifyDate

      # Obtener la fecha de grabación del video, si está disponible
      if date_recorded
        video.recorded_at = date_recorded
      else
        # no hay fecha de grabación
        video.recorded_at = nil
      end

      # cerrar y eliminar el archivo temporal
      tempfile.close
      tempfile.unlink
    end
  end
end