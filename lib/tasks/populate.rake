namespace :populate do
  desc "Populate database with roles and permissions"
  task roles_and_permissions: :environment do
    # por ahora queda así bien tranqui a modo de ejemplo, después se puede mejorar, la idea acá es crear todos los roles
    # que van si o si como admin y moderador y los CRUD de todos los controllers para las permissions
    # Create some roles
    admin_role = Role.find_or_create_by!(name: 'admin')
    user_role = Role.find_or_create_by!(name: 'user')

    # Create some trust levels
    default_trust_level = TrustLevel.find_or_create_by!(name: 'level 1', order: 1, days_visited: 0, viewed_events: 0, likes_received: 0, likes_given: 0, comments_count: 0)

    # Create some permissions
    permission1 = Permission.find_or_create_by!(name: 'tesrrt', action: 'read', subject_class: 'User')
    permission2 = Permission.find_or_create_by!(name: 'test 2', action: 'write', subject_class: 'User')

    # Associate permissions with roles
    admin_role.permissions << [permission1, permission2]
    user_role.permissions << [permission2]
    default_trust_level.permissions << [permission1, permission2]

    admin_role.save
    user_role.save
    default_trust_level.save
  end
end
