namespace :cron do
  desc 'update user trust levels'
  task update_trust_levels: :environment do
    User.update_trust_levels
  end
end
