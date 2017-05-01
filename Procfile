sidekiq: bundle exec sidekiq -q default -q mailgate -q mailers -q dag_links --environment ${RAILS_ENV:-production} --logfile log/sidekiq.log
sidekiq-cache-1: bundle exec sidekiq -q cache -c 1 --environment ${RAILS_ENV:-production} --logfile log/sidekiq-cache.log
sidekiq-cache-2: bundle exec sidekiq -q cache -c 1 --environment ${RAILS_ENV:-production} --logfile log/sidekiq-cache.log
sidekiq-cache-3: bundle exec sidekiq -q cache -c 1 --environment ${RAILS_ENV:-production} --logfile log/sidekiq-cache.log
sidekiq-cache-4: bundle exec sidekiq -q cache -c 1 --environment ${RAILS_ENV:-production} --logfile log/sidekiq-cache.log
sidekiq-cache-5: bundle exec sidekiq -q cache -c 1 --environment ${RAILS_ENV:-production} --logfile log/sidekiq-cache.log
sidekiq-slow-1: bundle exec sidekiq -q slow -c 1 --environment ${RAILS_ENV:-production} --logfile log/sidekiq-slow.log
sidekiq-slow-2: bundle exec sidekiq -q slow -c 1 --environment ${RAILS_ENV:-production} --logfile log/sidekiq-slow.log
sidekiq-slow-3: bundle exec sidekiq -q slow -c 1 --environment ${RAILS_ENV:-production} --logfile log/sidekiq-slow.log
sidekiq-retry: bundle exec sidekiq -q retry -c 5 --environment ${RAILS_ENV:-production} --logfile log/sidekiq-retry.log
notifications: bundle exec rake notifications:worker >> log/notifications.log 2>&1