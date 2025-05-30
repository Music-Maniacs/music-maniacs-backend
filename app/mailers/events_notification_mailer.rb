class EventsNotificationMailer < ApplicationMailer
  def new_event_from_follows
    @user = params[:user]
    @event = params[:event]
    mail(to: @user.email, subject: 'nuevo evento de un perfil que sigues!')
  end

  def event_updates_to_followers
    @user = params[:user]
    @event = params[:event]
    @changes = params[:changes]
    mail(to: @user.email, subject: "cambios en el evento: #{@event.name}")
  end

  def event_destroys_to_followers
    @user = params[:user]
    @event = params[:event]
    mail(to: @user.email, subject: "El evento #{@event.name} fue eliminado")
  end
end
