class BvMapping < ActiveRecord::Base
  attr_accessible :bv_name, :plz, :town

  def self.find_or_create(args)
    plz = args[:plz] || raise('Keine :plz angegeben.')
    town = args[:town] || raise('Keine :town angegeben.')
    self.where(plz: plz, town: town).first || self.create(args)
  end
end
