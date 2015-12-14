class BvMapping < ActiveRecord::Base
  attr_accessible :bv_name, :plz, :town
  
  # # TODO: Diese Methode müssen wir neu implementieren, wenn bekannt ist,
  # # wie die neuen Modifikationen aussehen werden, d.h. ob wir Ort oder Ort+PLZ
  # # angeben.
  # #
  # def self.find_or_create(args)
  #   self.find_by_plz(args[:plz]) || self.create(args)
  # end
end
