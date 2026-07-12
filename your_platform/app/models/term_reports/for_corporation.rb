class TermReports::ForCorporation < TermReport

  def corporation
    group
  end

  def semester_calendar
    corporation.semester_calendars.find_by term_id: term.id
  end

  def fill_info
    raise ActiveRecord::RecordInvalid, "term report has already been #{self.state.to_s}." if self.state
    self.delete_cache
    self.number_of_events = events.count
    # Counted per user, not per membership row: a user can have
    # several direct memberships in the corporation's subtree, and a
    # status change within the term must not count as a new member.
    self.number_of_members = Membership.where(id: corporation.membership_ids_for_member_list)
      .at_time(end_of_term).distinct.count(:descendant_id)
    self.number_of_new_members = corporation.new_member_count(during: term_time_range)
    self.number_of_membership_ends = corporation.former_members_parent.try(:new_member_count, during: term_time_range) || 0
    self.number_of_deaths = corporation.deceased.try(:new_member_count, during: term_time_range) || 0
    self.balance = number_of_new_members - number_of_membership_ends - number_of_deaths
    self.save

    self.becomes(CorporationScore).fill_score_info
  end

  def self.by_corporation_and_term(corporation, term)
    self.find_or_create_by(group_id: corporation.id, term_id: term.id)
  end

  def officer_group(key)
    group.officers_groups_of_self_and_descendant_groups.select { |g| g.has_flag? key }.first
  end

  def officer(key)
    officer_group(key).memberships.at_time(end_of_term).order(:valid_from).first.try(:user) if officer_group(key)
  end

  def events
    semester_calendar.try(:events) || []
  end

end



