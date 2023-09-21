class Users::UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[user_info update destroy]
  USER_TO_JSON = { include: { links: { only: %i[id url title] },
                              images: { methods: %i[full_url] },
                              role: {} } }.freeze

  def user_info
    render json: current_user.as_json(USER_TO_JSON), status: :ok
  end

  def update
    user = current_user

    images_params = params[:images] if params[:images].present? # imágenes a crear
    # Parsea el JSON en params[:user] y convierte las claves a símbolos
    user_params = JSON.parse(params[:user]).deep_symbolize_keys # Para la eliminacion

    if params[:images].present? # Count total
      # Verifica si la actualización excede el límite de imágenes
      total_images_count = user.images.count + params[:images].size

      if total_images_count > 2
        render json: { error: 'Too many images (maximum is 2)' }, status: :unprocessable_entity # Dejar error al front?
        return
      end
    end

    if user_params[:images_attributes].present? # Eliminacion imagenes
      # Extrae las imágenes y elimina el atributo images_attributes
      images_params_delete = user_params.delete(:images_attributes) # Imagenes a borrar

      images_params_delete.each do |image_params| # Borra por cada imagen
        image_id = image_params[:id]
        destroy = image_params[:_destroy]

        if image_id.present? && destroy == true
          image = Image.find(image_id)
          image.destroy if image.present? && image.imageable == user
        end
      end
    end

    if user.update(user_params_update)

      if images_params.present? # Agrega imagenes
        images_params.each do |image_param|
          user.images.create(file: image_param)
        end
      end

      render json: user.as_json(methods: :state, include: %i[links role images]), status: :ok
    else
      render json: { errors: user.errors.details }, status: :unprocessable_entity
    end
  end

  def destroy
    user = current_user
    user.deleted_at = Time.now

    if user.save
      head :no_content, status: :ok
    else
      render json: { errors: user.errors.details }, status: :unprocessable_entity
    end
  end

  private

  # def validate_image_count
  #   current_user.validate_image_count
  # end

  def user_params_update
    JSON.parse(params.require(:user)).deep_symbolize_keys.slice(:username,
                                                                :email,
                                                                :full_name,
                                                                :biography,
                                                                :role_id,
                                                                links_attributes: %i[url title _destroy id])
  end
end