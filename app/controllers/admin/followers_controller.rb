class Admin::FollowersController < ApplicationController
  before_action :authenticate_user!

  def follow_entity(entity)
    follower = Follower.new
    follower.user_id = current_user.id
    follower.followable = entity
    follower.save
  end

  # Acción para seguir un espacio de eventos
  def follow_venue
    venue_to_follow = Venue.find(params[:id])

    puts "Current User: #{current_user.inspect}" # esto da nill
    puts "venue_to_follow: #{venue_to_follow.inspect}"

    if current_user.following?(venue_to_follow, current_user)
      render json: { errors: current_user.errors.details }, status: :unprocessable_entity
    else
      if follow_entity(venue_to_follow)
        render status: :ok
      else
        render json: { errors: follower.errors.details }, status: :unprocessable_entity
      end
    end
  end

  # # Acción para dejar de seguir un espacio de eventos
  # def unfollow_event_space
  #   space_to_unfollow = EventSpace.find(params[:event_space_id])
  #   unfollow_action(current_user, space_to_unfollow)
  # end

  # Acción para seguir una productora
  def follow_producer
    producer_to_follow = Producer.find(params[:id])

    if current_user.following?(producer_to_follow)
      render json: { errors: current_user.errors.details }, status: :unprocessable_entity
    else
      if follow_entity(producer_to_follow)
        render status: :ok
      else
        render json: { errors: follower.errors.details }, status: :unprocessable_entity
      end
    end
  end

  # Acción para dejar de seguir una productora
  # def unfollow_producer
  #   producer_to_unfollow = Producer.find(params[:producer_id])
  #   unfollow_action(current_user, producer_to_unfollow)
  # end

  # Acción para seguir un artista
  def follow_artist
    artist_to_follow = Artist.find(params[:id])

    if current_user.following?(artist_to_follow)
      render json: { errors: current_user.errors.details }, status: :unprocessable_entity
    else
      if follow_entity(artist_to_follow)
        render status: :ok
      else
        render json: { errors: follower.errors.details }, status: :unprocessable_entity
      end
    end
  end

  # Acción para dejar de seguir un artista
  # def unfollow_artist
  #   artist_to_unfollow = Artist.find(params[:id])
  #   unfollow_action(current_user, artist_to_unfollow)
  # end

  # Acción para seguir un evento
  # def follow_event
  #   event_to_follow = Event.find(params[:event_id])
  #   unless current_user.following?(event_to_follow)
  #     follower = current_user.followers.build(followable: event_to_follow)

  #     if follower.save
  #       redirect_to event_to_follow, notice: 'Has comenzado a seguir este evento.'
  #     else
  #       redirect_to event_to_follow, alert: 'No se pudo seguir este evento en este momento.'
  #     end
  #   else
  #     redirect_to event_to_follow, alert: 'Ya estás siguiendo este evento.'
  #   end
  # end

  # Acción para dejar de seguir un evento
  # def unfollow_event
  #   event_to_unfollow = Event.find(params[:event_id])
  #   unfollow_action(current_user, event_to_unfollow)
  # end

  # private
  #   # # def unfollow_action(user, target)
  #   # #   follower = user.followers.find_by(followable: target)
  #   # #   if follower
  #   # #     follower.destroy
  #   # #     redirect_to target, notice: "Has dejado de seguir #{target.class.name.titleize}."
  #   # #   else
  #   # #     redirect_to target, alert: "No estás siguiendo #{target.class.name.titleize}."
  #   # #   end
  # end
end
