class EventsNotificationMailer < ApplicationMailer
  def new_event_from_follows
    @user = params[:user]
    @event = params[:event]
    mail(to: @user.email, subject: 'nuevo evento de un perfil que sigues!')
  end

  def event_updates_to_followers
    @user = params[:user]
    @event = params[:event]
    mail(to: @user.email, subject: 'hubieron cambios en un evento que sigues')
  end
end
