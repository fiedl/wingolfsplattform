# Be sure to restart your server when you modify this file.

# The key mirrors ApplicationRecord.storage_namespace('session'),
# inlined: the session store is middleware configuration and runs
# before the autoloaders, which must not be asked for ApplicationRecord
# since rails 7.
session_key = ["your_platform", Rails.env.to_s, ENV['TEST_ENV_NUMBER'], "session"].compact.join("_")

Rails.application.config.session_store :cookie_store, key: session_key, domain: :all, tld_length: 2
