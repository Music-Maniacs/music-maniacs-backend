class Admin::FollowersController < ApplicationController
  before_action :authenticate_user!

  # Acción para seguir un espacio de eventos
  def follow_venue
    venue_to_follow = find_venue_by_id
    handle_follow(venue_to_follow)
  end

  # Acción para dejar de seguir un espacio de eventos
  def unfollow_venue
    venue_to_unfollow = Venue.find(params[:id])
    handle_unfollow(venue_to_unfollow)
  end

  # Acción para seguir una productora
  def follow_producer
    producer_to_follow = find_producer_by_id
    handle_follow(producer_to_follow)
  end

  # Acción para dejar de seguir una productora
  def unfollow_producer
    producer_to_unfollow = Producer.find(params[:id])
    handle_unfollow(producer_to_unfollow)
  end

  # Acción para seguir un artista
  def follow_artist
    artist_to_follow = find_artist_by_id
    handle_follow(artist_to_follow)
  end

  # Acción para dejar de seguir un artista
  def unfollow_artist
    artist_to_unfollow = Artist.find(params[:id])
    handle_unfollow(artist_to_unfollow)
  end

  private

  def venue_params
    params.require(:venue).permit(:id)
  end

  def producer_params
    params.require(:producer).permit(:id)
  end

  def artist_params
    params.require(:artist).permit(:id)
  end

  def find_venue_by_id
    Venue.find(venue_params[:id])
  end

  def find_producer_by_id
    Producer.find(producer_params[:id])
  end

  def find_artist_by_id
    Artist.find(artist_params[:id])
  end

  def follow_action(entity)
    follower = Follower.new
    follower.user_id = current_user.id
    follower.followable = entity
    follower.followable_id = entity.id
    follower.save
  end

  def unfollow_action(user, entity)
    follower = user.followers.find_by(followable: entity)
    if follower
      follower.destroy
      render status: :ok
    else
      render json: { errors: follower.errors.details }, status: :unprocessable_entity
    end
  end

  def handle_follow(entity_to_follow)
    if current_user.following?(entity_to_follow, current_user)
      render json: { errors: current_user.errors.details }, status: :unprocessable_entity
    else
      if follow_action(entity_to_follow)
        render status: :ok
      else
        render json: { errors: follower.errors.details }, status: :unprocessable_entity
      end
    end
  end

  def handle_unfollow(entity_to_unfollow)
    unfollow_action(current_user, entity_to_unfollow)
  end
end
