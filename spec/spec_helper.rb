require 'rubygems'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

require 'rspec/rails'
require 'nokogiri'
require 'capybara/poltergeist'
require 'rspec/expectations'

Dir[Rails.root.join('spec/support/**/*.rb')].each {|f| require f}
Dir[Rails.root.join('vendor/engines/your_platform/spec/support/**/*.rb')].each {|f| require f}

FactoryGirl.definition_file_paths = %w(spec/factories vendor/engines/your_platform/spec/factories)
FactoryGirl.reload

Geocoder.configure( lookup: :test )

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.include RSpec::Matchers
  config.include Rails.application.routes.url_helpers
  config.include FactoryGirl::Syntax::Methods
  config.include TimeTravel
  
  config.run_all_when_everything_filtered = true
  config.infer_base_class_for_anonymous_controllers = false
  
  config.treat_symbols_as_metadata_keys_with_true_values = true
  
  config.around(:each) do |spec|
    ActiveRecord::Base.transaction do
      spec.call
      raise ActiveRecord::Rollback
    end
  end
end

I18n.default_locale = :de
I18n.locale = :de
