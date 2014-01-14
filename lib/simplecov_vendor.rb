require 'simplecov'
SimpleCov.adapters.define 'vendor' do
  load_adapter 'rails'

  add_group 'Vendor', 'vendor/engines/your_plattform'
end
