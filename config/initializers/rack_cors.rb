Rails.application.config.middleware.insert_before 0, Rack::Cors do

  # Allow sign-in from our form at yourplatform.io.
  #
  allow do
    origins 'yourplatform.io', 'wingolf.yourplatform.io', 'wingolf.io'

    resource '*'
  end
end
