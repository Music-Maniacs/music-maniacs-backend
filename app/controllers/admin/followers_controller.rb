class Admin::FollowersController < ApplicationController
  before_action :authenticate_user!

  # Acción para seguir un espacio de eventos
  def follow_venue
    venue_to_follow = Venue.find(params[:id])

    puts "venue_to_follow: #{venue_to_follow.inspect}"

    if current_user.following?(venue_to_follow, current_user)
      render json: { errors: current_user.errors.details }, status: :unprocessable_entity
    else
      if follow_action(venue_to_follow)
        render status: :ok
      else
        render json: { errors: follower.errors.details }, status: :unprocessable_entity
      end
    end
  end

  # Acción para dejar de seguir un espacio de eventos
  def unfollow_venue
    venue_to_unfollow = Venue.find(params[:id])
    unfollow_action(current_user, venue_to_unfollow)
  end

  # Acción para seguir una productora
  def follow_producer
    producer_to_follow = Producer.find(params[:id])

    if current_user.following?(producer_to_follow, current_user)
      render json: { errors: current_user.errors.details }, status: :unprocessable_entity
    else
      if follow_action(producer_to_follow)
        render status: :ok
      else
        render json: { errors: follower.errors.details }, status: :unprocessable_entity
      end
    end
  end

  # Acción para dejar de seguir una productora
  def unfollow_producer
    producer_to_unfollow = Producer.find(params[:id])
    puts "producer_to_unfollow: #{producer_to_unfollow.inspect}"
    unfollow_action(current_user, producer_to_unfollow)
  end

  # Acción para seguir un artista
  def follow_artist
    artist_to_follow = Artist.find(params[:id])

    if current_user.following?(artist_to_follow, current_user)
      render json: { errors: current_user.errors.details }, status: :unprocessable_entity
    else
      if follow_action(artist_to_follow)
        render status: :ok
      else
        render json: { errors: follower.errors.details }, status: :unprocessable_entity
      end
    end
  end

  # Acción para dejar de seguir un artista
  def unfollow_artist
    artist_to_unfollow = Artist.find(params[:id])
    puts "artist_to_unfollow: #{artist_to_unfollow.inspect}"
    unfollow_action(current_user, artist_to_unfollow)
  end

  private

  def follow_action(entity)
    follower = Follower.new
    follower.user_id = current_user.id
    follower.followable = entity
    follower.followable_id = entity.id
    follower.save
  end

  def unfollow_action(user, entity)
    puts "PROBLEMATIC_ENTITY: #{entity.inspect}"
    follower = user.followers.find_by(followable: entity)
    if follower
      follower.destroy
      render status: :ok
    else
      render json: { errors: follower.errors.details }, status: :unprocessable_entity
    end
  end
end
