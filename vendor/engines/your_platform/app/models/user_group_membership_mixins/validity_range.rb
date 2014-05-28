#
# In this project, user group memberships do not neccessarily last forever.
# They can begin at some time and end at some time. This is expressed by the
# ValidityRange of a membership.
#
# We have extracted the core of this functionality out into the
# `temporal_scopes` gem:
# 
#     https://github.com/fiedl/temporal_scopes
#
# @example Validity range.
#     membership.valid_from  # =>  time
#     membership.valid_to    # =>  time
#
# @example Archiving a record.
#     membership.archive
#     membership.invalidate  # the same as #archive
# 
# @example Scopes.
#
#     UserGroupMembership.now
#     UserGroupMembership.past
#     UserGroupMembership.with_past
#
# By default, the `now` scope is applied, i.e. only memberships are 
# found that are valid at present time. To override this scope, use
# `with_past`.
#
module UserGroupMembershipMixins::ValidityRange
  
  extend ActiveSupport::Concern

  included do 
    attr_accessible :valid_from, :valid_to, :valid_from_localized_date
    
    has_temporal_scopes
    before_validation :set_valid_from_to_now
  end
  
  
  def valid_from_localized_date
    self.valid_from ? I18n.localize(self.valid_from.try(:to_date)) : ""
  end
  def valid_from_localized_date=(new_date)
    self.valid_from = new_date.to_datetime
    valid_from_will_change!
  end

  def set_valid_from_to_now(force = false)
    self.valid_from ||= Time.zone.now if self.new_record? or force
    return self
  end
  
  
  # For compatibily reasons, this is an alias for #archive.
  # 
  # @param options [Hash]
  # @option options :at [DateTime] the time of invalidation.
  #
  def invalidate(options = {})
    self.archive(options)
  end
  
  # This method determines whether the membership can be invalidated.
  # Direct memberships can be invalidated, whereas indirect memberships cannot.
  # The validity of indirect memberships is derived from the validity of the direct ones.
  #
  def can_be_invalidated?
    self.direct?
  end

end
