sidekiq: bundle exec sidekiq -q default -q mailgate -q mailers -q dag_links -c 10 --environment ${RAILS_ENV:-production} --logfile log/sidekiq.log
sidekiq-cache-1: bundle exec sidekiq -q cache -c 3 --environment ${RAILS_ENV:-production} --logfile log/sidekiq-cache.log
sidekiq-slow-1: bundle exec sidekiq -q slow -c 1 --environment ${RAILS_ENV:-production} --logfile log/sidekiq-slow.log
sidekiq-retry: bundle exec sidekiq -q retry -c 5 --environment ${RAILS_ENV:-production} --logfile log/sidekiq-retry.log
notifications: bundle exec rake notifications:worker >> log/notifications.log 2>&1