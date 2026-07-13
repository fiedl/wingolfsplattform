# Object-scoped settings (user.settings.dark_mode,
# page.settings.teaser_image_url, Setting.app_name), vendored from
# rails-settings-cached 0.7.1.
#
# Vendored during the rails upgrade
# (https://github.com/fiedl/wingolfsplattform/issues/126): the gem's
# 2.x line dropped object-scoped settings entirely, and the settings
# table holds production data in the 0.7 format. Like the vendored
# DAG code, this keeps the storage format and API stable while rails
# moves on.
#
# Note for the ruby 3.1 hop: RailsSettings::Settings#value uses
# YAML.load, which becomes safe-load in ruby 3.1 — switch to
# YAML.unsafe_load or permitted_classes there.
#
require_relative 'rails_settings/settings'
require_relative 'rails_settings/base'
require_relative 'rails_settings/default'
require_relative 'rails_settings/extend'
require_relative 'rails_settings/scoped_settings'
