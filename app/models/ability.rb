# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    # Define abilities for the user here. For example:
    #
    #   return unless user.present?
    #   can :read, :all
    #   return unless user.admin?
    #   can :manage, :all
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, published: true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md
    return if user.role.blank? # los guest no tienen permisos (solo endpoints publicos), en el front para simplificar se consultan permisos igual

    can :manage, :all if user.admin?

    user.role.permissions.each do |permission|
      if permission.subject_id.nil?
        can permission.action.to_sym, permission.subject_class.constantize
      else
        can permission.action.to_sym, permission.subject_class.constantize, id: permission.subject_id
      end
    end
  end
end
