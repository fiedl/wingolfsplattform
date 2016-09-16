# -*- coding: utf-8 -*-

# This extends the your_platform ProfileFIeld model.
require_dependency YourPlatform::Engine.root.join( 'app/models/profile_field' ).to_s

# This is the re-opened ProfileField class. All kinds of ProfileFields
# inherit from this class.
#
class ProfileField

  after_save { adopt_profileable_bv }

  def adopt_profileable_bv
    if self.kind_of?(ProfileFieldTypes::Address) && self.profileable.kind_of?(User) && self.profileable.alive? && self.profileable.wingolfit?
      self.delete_cache
      self.profileable.adapt_bv_to_primary_address
    elsif self.parent.kind_of?(ProfileFieldTypes::Address) and self.key == 'postal_code'
      self.parent.delay_for(10.seconds).adopt_profileable_bv
    end
  end

  # List all possible types. This is needed for code injection security checks.
  #
  self.singleton_class.send :alias_method, :orig_possible_types, :possible_types
  def self.possible_types
    self.orig_possible_types + [
      ProfileFieldTypes::Klammerung
    ]
  end

end

