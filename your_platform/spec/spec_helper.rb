# The engine specs run against the wingolfsplattform application and use
# the same spec configuration. This shim keeps `cd your_platform && rspec`
# working; the canonical helper lives in the application:
#
#     spec/spec_helper.rb
#
require File.expand_path('../../../spec/spec_helper', __FILE__)
