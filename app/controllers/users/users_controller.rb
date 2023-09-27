class Users::UsersController < ApplicationController
  before_action :authenticate_user!, only: [:user_info]

  def user_info
    render json: current_user.as_json(include: :role), status: :ok
  end

  def update
    user = current_user

    # images_params = params[:images]

    # # Procesamiento de imágenes
    # image_params_cover = params[:images][:cover] if images_params.present? && params[:images][:cover].present?
    # image_params_profile = params[:images][:profile] if images_params.present? && params[:images][:profile].present?

    # #### Creacion de imagenes ####

    # create_and_save_image(user, image_params_cover, false) if image_params_cover.present?
    # create_and_save_image(user, image_params_profile, true) if image_params_profile.present?

    # #### Eliminacion de imagenes ####

    # # Parsea el JSON en params[:user] y convierte las claves a símbolos
    # user_params = JSON.parse(params[:user]).deep_symbolize_keys # Para la eliminacion

    # # Eliminacion imagenes (capa extra se seguridad)
    # if user_params[:images_attributes].present?
    #   # Extrae las imágenes y elimina el atributo images_attributes
    #   images_params_delete = user_params.delete(:images_attributes) # Imagenes a borrar

    #   images_params_delete.each do |image_params| # Borra por cada imagen
    #     image_id = image_params[:id]
    #     destroy = image_params[:_destroy]

    #     if image_id.present? && destroy == true
    #       image = Image.find(image_id)
    #       image.destroy if image.present? && image.imageable == user
    #     end
    #   end
    # end

    if user.update(user_params_update)
      render json: user.as_json(methods: :state, include: %i[links role images]), status: :ok
    else
      render json: { errors: user.errors.details }, status: :unprocessable_entity
    end
  end

  private

  def user_params_update
    JSON.parse(params.require(:user)).deep_symbolize_keys.slice(:username,
                                                                :email,
                                                                :full_name,
                                                                :biography,
                                                                :role_id,
                                                                :links_attributes)
  end
end
