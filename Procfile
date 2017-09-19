web: bundle exec thin start -p $PORT
sidekiq: bundle exec sidekiq -C config/sidekiq.yml
websockets: bundle exec rake websocket_rails:start_server
