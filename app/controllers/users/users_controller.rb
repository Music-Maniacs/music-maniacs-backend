class Users::UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[user_info update]
  USER_TO_JSON_UPDATE = { methods: %i[state],
                          include: %i[links role profile_image cover_image] }.freeze

  def user_info
    render json: current_user.as_json(include: :role), status: :ok
  end

  def update
    user = current_user

    # Parsea el JSON en params[:user] y convierte las claves a símbolos
    user_params = JSON.parse(params[:user]).deep_symbolize_keys # Para la eliminacion

    # Recuperacion de imagen desde params
    image_params_cover = params[:cover_image] if params[:cover_image].present?
    image_params_profile = params[:profile_image] if params[:profile_image].present?

    #### CREATE UPDATE IMAGES ####
    update_image(user, image_params_cover, 'cover') if image_params_cover.present?
    update_image(user, image_params_profile, 'profile') if image_params_profile.present?

    #### DESTROY IMAGES #### (con comprobacion de permiso para borrar)
    if user_params[:images_attributes].present?
      # Extrae las imágenes y elimina el atributo images_attributes
      images_to_delete = user_params.delete(:images_attributes) # Imagenes a borrar
      destroy_image(user, images_to_delete)
    end

    if user.update(user_params_update)
      render json: user.as_json(USER_TO_JSON_UPDATE), status: :ok
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

  def update_image(user, image_params, image_type)
    if user.public_send("#{image_type}_image").present?
      user.public_send("#{image_type}_image").file.purge
      user.public_send("#{image_type}_image").file.attach(image_params)
    else
      user.public_send("#{image_type}_image=", Image.new(file: image_params, image_type: image_type))
    end
  end

  def destroy_image(user, images_params_delete)
    images_params_delete.each do |image_params| # Borra por cada imagen
      image_id = image_params[:id]
      destroy = image_params[:_destroy]

      if image_id.present? && destroy == true
        image = Image.find(image_id)
        # destruye la imagen enviada si esta es portada o perfil del usuario
        # Si es la imagen de portada o de perfil, la eliminamos y actualizamos el usuario
        if image == user.cover_image
          user.update(cover_image: nil)
        elsif image == user.profile_image
          user.update(profile_image: nil)
        end
        image.destroy
      end
    end
  end
end
