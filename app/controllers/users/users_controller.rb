class Users::UsersController < ApplicationController
  before_action :authenticate_user!, only: [:user_info]

  def user_info
    render json: current_user.as_json(include: :role), status: :ok
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
end
