class TermReports::AlleWingolfiten < TermReport
  def fill_info
    self.number_of_members = Group.alle_wingolfiten.member_count(at: end_of_term)
    self.number_of_new_members = Group.alle_wingolfiten.new_member_count(during: term_time_range)
    self.number_of_deaths = Group.alle_verstorbenen_wingolfiten.new_member_count(during: term_time_range)
    self.number_of_membership_ends = Group.alle_wingolfiten.ended_membership_count(during: term_time_range) - number_of_deaths
    self.balance = number_of_new_members - number_of_membership_ends - number_of_deaths

    self.anzahl_aktivmeldungen = self.number_of_new_members
    self.anzahl_todesfaelle = self.number_of_deaths
    self.anzahl_austritte = self.number_of_membership_ends

    self.save
    return self
  end

  def self.for_term(term)
    term_report = self.find_or_create_by term_id: term.id
  end
end