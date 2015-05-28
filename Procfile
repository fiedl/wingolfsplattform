sidekiq: bundle exec sidekiq --environment ${RAILS_ENV:-production} --logfile log/sidekiq.log
notifications: bundle exec rake notifications:worker > log/notifications.log 2>&1