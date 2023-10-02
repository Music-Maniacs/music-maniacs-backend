class ProfilesController < ApplicationController
  before_action :authenticate_user!, except: %i[show reviews]

  USER_TO_JSON = { only: %i[username full_name biography email],

                   include: { links: { only: %i[id url title] },
                              last_reviews: { only: %i[id rating description created_at reviewable_type],
                                              include: { user: { only: %i[id full_name] } },
                                              methods: :anonymous },
                              # images: { only: %i[id], methods: %i[full_url] },
                              user_stat: { except: %i[id user_id created_at updated_at] },
                              role: { only: %i[id name] } } }.freeze

  def info
    render json: current_user.as_json(include: :role), status: :ok
  end

  def change_password
    if current_user.update(user_params_change_password)
      render head: :no_content, status: :ok
    else
      render json: { errors: current_user.errors.details }, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user.destroy
      head :no_content, status: :ok
    else
      render json: { errors: current_user.errors.details }, status: :unprocessable_entity
    end
  end

  def show
    user = User.find(params[:id])
    render json: user.as_json(USER_TO_JSON), status: :ok
  end

  def reviews
    user = User.find(params[:id])
    reviews = user.reviews.page(params[:page]).per(params[:per_page])

    render json: { data: reviews.as_json(Review::TO_JSON), pagination: pagination_info(reviews) }
  end

  def show_followed_by_name
    # Busca en params [:q] si es busqueda por nombre, tipo o incluye params[:q]
    params_name = params.dig(:q, :followable_name_cont).gsub('"', '') if params.dig(:q, :followable_name_cont).present?

    if params_name.present? # Busqueda por nombre
      followable_name = params_name # Recupera de params

      # Busca en las entidades que coincidan con :followable_name_cont
      followed_entities = current_user.follows.includes(:followable).where(followable_type: %w[Venue Producer Artist Event])
      # Filtra las entidades basándonos en el atributo followable_name
      followed_entities = followed_entities.select do |follow|
        followable = follow.followable
        followable.present? && followable.name.include?(followable_name)
      end
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

  %w[artist producer venue event].each do |entity|
    define_method "show_followed_#{entity.pluralize}" do
      followed_entities_search = current_user.send("followed_#{entity.pluralize}").ransack(params[:q])
      followed_entities = followed_entities_search.result(distinct: true).page(params[:page]).per(params[:per_page])

      render json: { data: followed_entities.as_json(only: %i[id name]),
                     pagination: pagination_info(followed_entities) }
    end
  end

  private

  def user_params_change_password
    params.require(:user).permit(:password, :password_confirmation)
  end
end