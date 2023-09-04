class Admin::FollowersController < ApplicationController
  before_action :authenticate_user!

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

  # Acción para seguir un espacio de eventos
  def follow_venue
    venue_to_follow = Venue.find(params[:venue_id])

    puts "Current User: #{current_user.inspect}" # esto da nill
    puts "user_to_follow: #{user_to_follow.inspect}"

    if current_user.following?(venue_to_follow)
      render json: { errors: current_user.errors.details }, status: :unprocessable_entity
    else
      follower = current_user.followers.build(followable: venue_to_follow)

      if follower.save
        render status: :ok
      else
        render json: { errors: current_user.errors.details }, status: :unprocessable_entity
      end
    end
  end

  # Acción para dejar de seguir un espacio de eventos
  def unfollow_event_space
    space_to_unfollow = EventSpace.find(params[:event_space_id])
    unfollow_action(current_user, space_to_unfollow)
  end

  # Acción para seguir una productora
  # def follow_producer
  #   producer_to_follow = Producer.find(params[:producer_id])
  #   unless current_user.following?(producer_to_follow)
  #   follower = current_user.followers.build(followable: producer_to_follow)

  #   if follower.save
  #     redirect_to producer_to_follow, notice: 'Has comenzado a seguir esta productora.'
  #   else
  #     redirect_to producer_to_follow, alert: 'No se pudo seguir esta productora en este momento.'
  #   end
  #   else
  #     redirect_to producer_to_follow, alert: 'Ya estás siguiendo esta productora.'
  #   end
  # end

  # Acción para dejar de seguir una productora
  # def unfollow_producer
  #   producer_to_unfollow = Producer.find(params[:producer_id])
  #   unfollow_action(current_user, producer_to_unfollow)
  # end

  private

  def unfollow_action(user, target)
    follower = user.followers.find_by(followable: target)
    if follower
      follower.destroy
      redirect_to target, notice: "Has dejado de seguir #{target.class.name.titleize}."
    else
      redirect_to target, alert: "No estás siguiendo #{target.class.name.titleize}."
    end
  end
end
