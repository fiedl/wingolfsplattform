sidekiq: bundle exec sidekiq -q default -q mailgate -q mailers -q dag_links --environment ${RAILS_ENV:-production} --logfile log/sidekiq.log
sidekiq-cache: bundle exec sidekiq -q cache -c 50 --environment ${RAILS_ENV:-production} --logfile log/sidekiq.log
sidekiq-retry: bundle exec sidekiq -q retry -c 5 --environment ${RAILS_ENV:-production} --logfile log/sidekiq.log
notifications: bundle exec rake notifications:worker >> log/notifications.log 2>&1