class Users::UsersController < ApplicationController
  before_action :authenticate_user!
  USER_TO_JSON = { only: %i[username full_name biography],
                   include: { links: { only: %i[id url title] },
                              images: { only: %i[id],
                                        methods: %i[full_url] },
                              role: { only: %i[id name] },
                              user_stat: { only: %i[id days_visited viewed_events likes_given
                                                    likes_received comments_count last_session penalty_score] } },
                   methods: %i[reviews] }.freeze

  def perfil
    render json: current_user.as_json(USER_TO_JSON), status: :ok
  end

  def user_info
    render json: current_user.as_json(include: :role), status: :ok
  end

  def update
    user = current_user

    images_params = params[:images]

    # Procesamiento de imágenes
    image_params_cover = params[:images][:cover] if images_params.present? && params[:images][:cover].present?
    image_params_profile = params[:images][:profile] if images_params.present? && params[:images][:profile].present?

    ### Contador total de imágenes ####
    if params[:images].present?
      profile_images_count = params[:images][:profile].present? ? 1 : 0
      cover_images_count = params[:images][:cover].present? ? 1 : 0

      total_images_count = user.images.count + profile_images_count + cover_images_count

      if total_images_count > 2
        render json: { error: 'Too many images (maximum is 2)' }, status: :unprocessable_entity
        return
      end
    end

    #### Creacion de imagenes ####

    create_and_save_image(user, image_params_cover, false) if image_params_cover.present?
    create_and_save_image(user, image_params_profile, true) if image_params_profile.present?

    #### Eliminacion de imagenes ####

    # Parsea el JSON en params[:user] y convierte las claves a símbolos
    user_params = JSON.parse(params[:user]).deep_symbolize_keys # Para la eliminacion

    # Eliminacion imagenes (capa extra se seguridad)
    if user_params[:images_attributes].present?
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

  def change_password
    # Para recorrer seguramente el anidamiento
    if params.dig(:user, :password).present? &&
       params.dig(:user, :password_confirmation).present? &&
       params.dig(:user, :password_confirmation) == params.dig(:user, :password)

      if current_user.update(user_params_change_password)
        render head: :no_content, status: :ok
      else
        render json: { errors: user.errors.details }, status: :unprocessable_entity
      end
    end
  end

  def show_followed
    # Busca en params [:q] si es busqueda por nombre, tipo o incluye params[:q]
    params_name = params.dig(:q, :followable_name_cont).gsub('"', '') if params.dig(:q, :followable_name_cont).present?
    params_type = params.dig(:q, :followable_type_cont) if params.dig(:q, :followable_type_cont).present?

    if params_name.present? # Busqueda por nombre
      followable_name = params_name # Recupera de params

      # Busca en las entidades que coincidan con :followable_name_cont
      followed_entities = current_user.follows.includes(:followable).where(followable_type: %w[Venue Producer Artist Event])

      # Filtra las entidades basándonos en el atributo followable_name
      followed_entities = followed_entities.select do |follow|
        followable = follow.followable
        followable.present? && followable.name.include?(followable_name)
      end
    elsif params_type.present? # Busqueda por tipo
      followed_entities = current_user.follows.includes(:followable)
                                      .where(followable_type: params_type)
    else # Todas las entidades si no viene followable_name
      followed_entities = current_user.follows.includes(:followable)
    end
    # followed_entities sea un ActiveRecord::Relation
    followed_entities = Follow.where(id: followed_entities.map(&:id))

    # Pagina los resultados
    followed_entities = followed_entities.page(params[:page]).per(params[:per_page])

    # Mapea los datos
    follow_data = followed_entities.map do |follow|
      {
        followable_id: follow.followable_id,
        followable_type: follow.followable_type,
        name: follow.followable_name
      }
    end
    render json: { data: follow_data, pagination: pagination_info(followed_entities) }, status: :ok
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

  def user_params_change_password
    params.require(:user).permit(:password, :password_confirmation)
  end

  def create_and_save_image(user, image_params, is_profile)
    image = user.images.build
    image.file.attach(image_params)
    is_profile ? image.mark_as_profile : image.mark_as_cover

    # Asignar el usuario a la imagen
    image.imageable = user

    image.save
  end
end