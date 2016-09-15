class Groups::AktiveImBv < Groups::GeoSearchGroup

  delegate :bv_id, :bv_id=, to: :settings

  def bv
    Bv.find bv_id if bv_id
  end

  def users_within_bv
    ProfileFieldTypes::Address.all.select { |address_field|
      (address_field.bv == self.bv) && (address_field.profileable.kind_of?(User))
    }.collect(&:profileable)
  end

  def member_ids
    cached { apply_status_selector(users_within_bv).map(&:id) }
  end

  def apply_status_selector(users)
    super.select do |user|
      user.aktiver? &&
      (not user.corporations.include? corporation)
    end
  end

end