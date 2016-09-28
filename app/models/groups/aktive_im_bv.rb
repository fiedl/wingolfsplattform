class Groups::AktiveImBv < Groups::GeoSearchGroup

  delegate :bv_id, :bv_id=, to: :settings

  def bv
    Bv.find bv_id if bv_id
  end

  def users_within_bv
    ProfileFieldTypes::Address.all.select { |address_field|
      (address_field.bv_id == self.bv_id) && (address_field.profileable_type == "User")
    }.collect(&:profileable)
  end

  def member_ids
    cached { apply_status_selector(users_within_bv).map(&:id) }
  end

  def apply_status_selector(users)
    super.select do |user|
      (not user.philister?) &&
      (not user.corporations.include? corporation)
    end
  end

end