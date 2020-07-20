neo4j: docker-compose up neo4j
webpack: cd ~/rails/your_platform && bin/webpack-dev-server
sidekiq: bundle exec sidekiq -q default -q mailgate -q mailers -q dag_links -q cache -q slow
notifications: bundle exec rake notifications:worker
web: bundle exec rails server --port 3001
vue-devtools: PORT=8098 vue-devtools
