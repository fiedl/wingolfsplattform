#
# This file contains the configuration of our test suite.
# We are using the following tools:
#
# RSpec             Defining test-driven or behavior-driven specifications of
#                   software components.
#                   http://rspec.info/
#
# rspec-rails       Integration of RSpec into Rails, providing generators, et cetera.
#                   https://github.com/rspec/rspec-rails
#
# Spring             Keeping some less frequently changing components in memory
#                   in order to increase test performance, i.e. minimize the time
#                   Guard needs to restart the tests.
#                   https://github.com/rails/spring
#
# Capybara          Simulating user interaction in order to write high level
#                   integration tests.
#                   https://github.com/jnicklas/capybara
#
# Selenium          http://www.seleniumhq.org
# Chrome-Headless   Feature specs run in a headless chrome, either remote
#                   (dockerized, CHROME_URL) or local.
#
# FactoryBot        Library to provide test data objects.
#                   https://github.com/thoughtbot/factory_bot
#

# Required Basic Libraries
# ==========================================================================================

require 'rubygems'


# Required Application Environment
# ----------------------------------------------------------------------------------------
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

# Stop if the database is not migrated. The migration path is relative
# by default; anchor it so the check also works when the specs are
# started from the engine directory (your_platform/).
ActiveRecord::Migrator.migrations_paths = [Rails.root.join('db/migrate').to_s]
ActiveRecord::Migration.check_pending!


# The original setting whether the renew-cache mechanism should be skipped
# falling back to the delete-cache mechanism.
#
# This is default for model specs, since it makes no difference to them and the
# delete-cache mechanism is faster as caches are only filled when needed instead
# of eagerly filling every cache.
#
ENV_NO_RENEW_CACHE = ENV['NO_RENEW_CACHE']
ENV_NO_CACHING = ENV['NO_CACHING']


# Required Libraries
# ----------------------------------------------------------------------------------------

require 'rspec/rails'
require 'nokogiri'
require 'selenium/webdriver'
require 'rspec/expectations'
require 'sidekiq/testing'
require 'rspec/retry'


# Required Support Files (that help you testing)
# ----------------------------------------------------------------------------------------

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.

Dir[Rails.root.join('spec/support/**/*.rb')].each {|f| require f}
Dir[YourPlatform::Engine.root.join('spec/support/**/*.rb')].each {|f| require f}


# Factories, Stubs and Mocks
# ----------------------------------------------------------------------------------------

# Mock objects are simplified objects ("stub") that are used rather than the
# real, more complex objects, e.g. in order to increase performance.
#
# Rather than `rspec-mocks` fixtures, we use FactoryBot instead.
#
FactoryBot.definition_file_paths = [
  Rails.root.join('spec/factories'),
  YourPlatform::Engine.root.join('spec/factories')
]

# In order to not hit the geocoding API, we use stub data for geocoding.
#
Geocoder.configure( lookup: :test )


# Capybara Configuration
# ----------------------------------------------------------------------------------------

require 'selenium/webdriver'

# Capybara 3 defaults to puma as its test server, which is not bundled.
Capybara.server = :webrick

# Feature specs run against a browser in a separate docker container
# (CHROME_URL), so the app under test must be reachable from there:
# bind to the container's address instead of localhost, one port per
# parallel test process.
Capybara.server_host = ENV.fetch("CAPYBARA_SERVER_HOST") { IPSocket.getaddress(Socket.gethostname) }
Capybara.server_port = ENV.fetch("CAPYBARA_SERVER_PORT", 33123).to_i + ENV['TEST_ENV_NUMBER'].to_i
Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--lang=de-DE')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-gpu')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1280,1024')
  options.add_preference(:prefs, { intl: { accept_languages: "de-DE,de" } })
  client = Selenium::WebDriver::Remote::Http::Default.new
  client.read_timeout = 360
  client.open_timeout = 60
  if ENV['CHROME_URL'].present?
    Capybara::Selenium::Driver.new(app, browser: :remote, url: ENV['CHROME_URL'], options: options, http_client: client)
  else
    options.add_argument('--headless')
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, http_client: client)
  end
end
Capybara.javascript_driver = :headless_chrome


# Set the time that Capybara should wait for ajax requests to be finished.
# The default is 2 seconds.
#
# See: https://github.com/jnicklas/capybara#asynchronous-javascript-ajax-and-friends
#
Capybara.default_max_wait_time = 30

# Background Jobs:
# Perform all background jobs immediately.
#
Sidekiq::Testing.inline!


# Rspec Configuration
# ----------------------------------------------------------------------------------------

RSpec.configure do |config|

  # Remember the status of each example, so that CI can rerun just the
  # failed ones. One file per parallel test process.
  #
  config.example_status_persistence_file_path = Rails.root.join("tmp/rspec/examples#{ENV['TEST_ENV_NUMBER']}.txt").to_s

  # Inclusion of helper methods.
  # ......................................................................................
  #
  # The methods contained in the modules marked to be included here, will be
  # available in the spec code, without being prefixed.
  #
  # For example, including the url_helpers allows to use `url_for(some_object)`
  # in the specs.
  #
  config.include RSpec::Matchers
  config.include Rails.application.routes.url_helpers
  config.include FactoryBot::Syntax::Methods
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers

  # TimeTravel abilities: time_travel 2.seconds
  # This can be used for caching, validity range, etc.
  #
  config.include TimeTravel

  # Factories for workflow bricks and access to the last sent email.
  config.include WorkflowKit::Factory
  config.include LastEmail
  config.include TimeMatchers

  # rspec-rails 3 will no longer automatically infer an example group's
  # spec type from the file location. You can explicitly opt-in to this
  # feature using this snippet:
  #
  config.infer_spec_type_from_file_location!

  # Enables both, the new `expect` and the old `should` syntax.
  # https://www.relishapp.com/rspec/rspec-expectations/docs/syntax-configuration
  #
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  # This introduces the method `wait_for_ajax`, which can be used when the Capybara
  # matchers do not wait properly for ajax code to be finished.
  # This is just a sleep command with a time determined by a simple benchmark.
  #
  # see spec/support/wait_for_ajax.rb
  #
  config.include WaitForAjax

  # Also, wait for the cache to invalidate.
  # This can be done with time_travel.
  #
  config.include WaitForCache

  # This introduces the methods `send_key(field_id, key)` and `press_enter(field_id)`.
  #
  config.include PressEnter

  # Auto complete fields
  #
  config.include AutoComplete

  # Debug
  # Call `debug` to enter pry.
  #
  config.include Debug

  # Devise test helper for controller tests
  config.include Devise::Test::ControllerHelpers, :type => :controller
  config.extend ControllerMacros, :type => :controller

  # Include Capybara helpers:
  config.include SessionSteps, type: :feature
  config.include HomePageSpecHelper, type: :feature
  config.include CapybaraHelper, type: :feature
  config.include WysiwygSpecHelper, type: :feature
  config.include TabSpecHelper, type: :feature

  # Devise test helper for controller tests
  config.include Devise::Test::ControllerHelpers, :type => :controller
  config.extend ControllerMacros, :type => :controller


  # Database Wiping Policy
  # ......................................................................................

  # For each separate test, the test database is wiped. There are several ways
  # to acomplish this. But, in high level integration tests, especially when
  # using AJAX requests, there may be complications:
  #   a) Several components are hitting the database: The test code as well as
  #        the simulated browser through Capybara.
  #   b) There may be cases when asynchronous requests hit the database
  #        after passing on to the next test, when the database is wiped again
  #        already. Beware of these cases, which really produce strange errors.
  #
  # Some resources on this topic:
  # * http://stackoverflow.com/questions/8178120/
  # * http://stackoverflow.com/questions/10692161/
  # * http://p373.net/2012/08/07/capybara-ajax-requirejs-and-how-to-pull-your-hair-out-in-8-easy-hours/

  config.use_transactional_fixtures = false

  config.before(:each) do

    # Do not use the renew_cache mechanism but fall back to delete_cache
    # in the model layer. This means that caches are created on the fly
    # when needed and not eagerly, which is faster.
    #
    if Capybara.current_driver == :rack_test # no integration test
      unless ENV_NO_RENEW_CACHE
        ENV['NO_RENEW_CACHE'] = "true"
      end
    else # integration test
      unless ENV_NO_RENEW_CACHE
        ENV['NO_RENEW_CACHE'] = nil
      end
    end

  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  config.before(:each) do

    # Finish all time travels of previous examples.
    Timecop.return

    # This distinction reduces the run time of the test suite by over a factor of 4:
    # From 40 to a couple of minutes, since the truncation method, which is slower,
    # is only used when needed by Capybara, i.e. when running integration tests,
    # possibly with asynchronous requests.
    #
    if Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :transaction
    else
      DatabaseCleaner.strategy = :truncation
    end
    DatabaseCleaner.start

    # Clear the cache.
    Rails.cache.clear unless ENV['NO_CACHING']

    # View fragments (`= cache :key do` in views) do not live in
    # `Rails.cache` but in the controller's own cache store, a file
    # store in tmp/cache that would otherwise leak between examples
    # and even between test runs.
    # See your_platform/config/initializers/cache.rb.
    ActionController::Base.cache_store.clear unless ENV['NO_CACHING']

    # # Clear cookies
    # # https://makandracards.com/makandra/16117
    # browser = Capybara.current_session.driver.browser
    # if browser.respond_to?(:clear_cookies)
    #   # Rack::MockSession
    #   browser.clear_cookies
    # elsif browser.respond_to?(:manage) and browser.manage.respond_to?(:delete_all_cookies)
    #   # Selenium::WebDriver
    #   browser.manage.delete_all_cookies
    # else
    #   raise "Don't know how to clear cookies. Weird driver?"
    # end

    # create the basic objects that are needed for all specs
    Group.find_or_create_everyone_group
    Group.find_or_create_corporations_parent_group
    Page.create_root
    Page.create_intranet_root
    Workflow.find_or_create_mark_as_deceased_workflow


    # Memory management
    # ......................................................................................

    # In order to free phantomjs memory, reset it after each spec.
    # This tries to avoid "failed to reach server".
    # https://github.com/fiedl/your_platform/pull/19#issuecomment-283803871
    #
    config.after(:each) { page.driver.reset! if defined?(page) && page.respond_to?(:driver) && page.driver.respond_to?(:reset!) }

    # Emulate Application Settings
    Setting.support_email = "support@example.com"

    # There are some actions FactoryBot needs to perform on every run.
    #
    FactoryBot.reload
    # Dir[Rails.root.join('../../spec/support/**/*.rb')].each {|f| require f}

  end

  config.after(:each, js: true) do
    # https://github.com/jnicklas/capybara/issues/1089
    #page.execute_script "window.stop()"
    give_it_some_time_to_finish_the_test_before_wiping_the_database
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    DatabaseCleaner.clean
  end

  # Spec Filtering: Focus on Current Specs
  # ......................................................................................

  # By including the `focus: true` in `describe` or `it` calls in the spec code,
  # cause the test suite to focus on these blocks, i.e. run only them. This can be
  # useful if are working on a tricky one.
  #
  # BUT REMEMBER to reove the `focus: true` before comitting the spec code.
  # Otherwise you prevent other tests from being run regularly.
  #
  # config.filter_run :focus => true
  #
  # EDIT: The filter is not set here, but using guar (i.e. in the Guardfile).
  # Thus, when using `bundle exec rake`, always all specs run,
  # which is important on the server.
  #
  config.run_all_when_everything_filtered = true


  # Further Rspec Configuration
  # ......................................................................................

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  #
  config.infer_base_class_for_anonymous_controllers = false

  # Examples tagged with :retry are retried, e.g. against browser timing
  # flakiness. The retry callback resets database, graph and browser
  # state, so the retry starts from a clean slate.
  #
  config.verbose_retry = false
  config.around :each, :retry do |example|
    example.run_with_retry retry: 3, retry_wait: 10
  end
  config.retry_callback = proc do |example|
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
    Capybara.reset! if example.metadata[:js]
  end

end


# Internationalization Settings
# ----------------------------------------------------------------------------------------

# Set the default locale.
# Notice: This has to be set to the same value as in config/application.rb.
# Because, in tests withs :js => true, the setting from config/application.rb is used.
#
I18n.default_locale = :de
I18n.locale = :de


# Request Host
# ----------------------------------------------------------------------------------------

# Override the request.host to be http://example.com rather than the default
# http://www.example.com. Otherwise, each spec would first trigger the non-www redirect
# in the your_platform application controller.
#
# http://stackoverflow.com/questions/6536503
#
# Edit: Does not work for all specs.
# For the moment, I've just deactivated the www redirect in the test env. --Fiedl
#
# Capybara.app_host = "http://localhost"


