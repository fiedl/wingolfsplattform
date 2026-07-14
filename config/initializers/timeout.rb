# config/initializers/timeout.rb
#
# rack-timeout >= 0.6 configures through the environment instead of
# the removed `Rack::Timeout.timeout=` writer. The middleware reads
# this when it is inserted (rack-timeout inserts itself in rails).
ENV['RACK_TIMEOUT_SERVICE_TIMEOUT'] ||= '600' # seconds
