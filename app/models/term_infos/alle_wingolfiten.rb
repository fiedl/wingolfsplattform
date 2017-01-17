class TermInfos::AlleWingolfiten < TermInfo
  def fill_info
    self.number_of_members = Group.alle_wingolfiten.memberships.at_time(end_of_term).count
    self.number_of_new_members = Group.alle_wingolfiten.memberships.with_past.where(valid_from: term_time_range).count
    self.number_of_membership_ends = Group.alle_wingolfiten.memberships.with_past.where(valid_to: term_time_range).count
    self.number_of_deaths = Group.alle_verstorbenen_wingolfiten.memberships.with_past.where(valid_from: term_time_range).count
    self.balance = number_of_new_members - number_of_membership_ends - number_of_deaths

    self.anzahl_aktivmeldungen = self.number_of_new_members
    self.anzahl_todesfaelle = self.number_of_deaths
    self.anzahl_austritte = self.number_of_membership_ends
    return self
  end

  def self.for_term(term)
    term.term_infos.build.becomes(TermInfos::AlleWingolfiten).fill_info
  end
end