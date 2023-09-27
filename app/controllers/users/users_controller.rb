class Users::UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[user_info update]

  def user_info
    render json: current_user.as_json(include: :role), status: :ok
  end

  def update
    user = current_user

    # Procesamiento de imágenes
    image_params_cover = params[:cover_image] if params[:cover_image].present?
    image_params_profile = params[:profile_image] if params[:profile_image].present?

    #### Creacion y actualizacion de imagenes ####
    puts "###################################################### #{image_params_cover}" if image_params_cover.present?
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ #{image_params_profile}" if image_params_profile.present?
    create_and_save_image(user, image_params_cover, false) if image_params_cover.present?
    create_and_save_image(user, image_params_profile, true) if image_params_profile.present?

    #### Eliminacion de imagenes ####

    # Parsea el JSON en params[:user] y convierte las claves a símbolos
    user_params = JSON.parse(params[:user]).deep_symbolize_keys # Para la eliminacion

    # Eliminacion imagenes (con comprobacion de permiso para borrar)
    if user_params[:images_attributes].present?
      # Extrae las imágenes y elimina el atributo images_attributes
      images_params_delete = user_params.delete(:images_attributes) # Imagenes a borrar

      images_params_delete.each do |image_params| # Borra por cada imagen
        image_id = image_params[:id]
        destroy = image_params[:_destroy]

        if image_id.present? && destroy == true
          image = Image.find(image_id)
          # destruye la imagen enviada si esta es portada o perfil del usuario
          image.destroy if image.present? && image == user.cover_image || image == user.profile_image
        end
      end
    end

    if user.update(user_params_update)
      render json: user.as_json(methods: :state, include: { links: {},
                                                            role: {},
                                                            cover_image: { methods: %i[full_url] },
                                                            profile_image: { methods: %i[full_url] } }), status: :ok
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

  def create_and_save_image(user, image_params, is_profile)
    case is_profile
    when true && user.profile_image.present?
      puts "ENTRO A true && user.profile_image.present?"
      user.profile_image.purge
      user.profile_image.file.attach(image_params)
    when false && user.cover_image.present?
      puts "ENTRO A false && user.cover_image.present?"
      user.cover_image.purge
      user.cover_image.file.attach(image_params)
    when true
      puts "ENTRO A TRUE"
      user.profile_image = Image.new(file: image_params)
    when false
      puts "ENTRO A FALSE"
      user.cover_image = Image.new(file: image_params)
    end
    save
  end
end
