require_dependency YourPlatform::Engine.root.join('app/models/term_info').to_s

module TermInfoAdditions

  def fill_info
    super
    self.anzahl_aktivmeldungen = number_of_new_members
    self.anzahl_aller_aktiven = corporation.aktivitas.memberships.at_time(end_of_term).count
    self.anzahl_burschungen = anzahl_neue "Burschen"
    self.anzahl_burschen = anzahl "Burschen"
    self.anzahl_fuxen = anzahl "Fuxen"
    self.anzahl_aktiver_burschen = anzahl "Aktive Burschen"
    self.anzahl_inaktiver_burschen_loci = anzahl "Inaktive Burschen loci"
    self.anzahl_inaktiver_burschen_non_loci = anzahl "Inaktive Burschen non loci"
    self.anzahl_konkneipwanten = anzahl "Konkneipanten"
    self.anzahl_philistrationen = corporation.philisterschaft.memberships.where(valid_from: term_time_range).count
    self.anzahl_philister = corporation.philisterschaft.memberships.at_time(end_of_term).count
    self.anzahl_austritte = number_of_membership_ends
    self.anzahl_austritte_aktive = corporation.former_members_parent.memberships.where(valid_from: term_time_range).select { |membership| not membership.user.ancestor_group_ids.include? Group.alle_philister.id }.count
    self.anzahl_austritte_philister = corporation.former_members_parent.memberships.where(valid_from: term_time_range).select { |membership| membership.user.ancestor_group_ids.include? Group.alle_philister.id }.count
    self.anzahl_todesfaelle = number_of_deaths
    self.save
  end

  #Anzahl Amtsträger
  ## Anzahl Kalender-Abonnenten

  def anzahl(group_name)
    corporation.sub_group(group_name).memberships.at_time(end_of_term).count
  end

  def anzahl_neue(group_name)
    corporation.sub_group(group_name).memberships.where(valid_from: term_time_range).count
  end

  def end_of_term
    term.end_at
  end

  def term_time_range
    term.time_range
  end

end

class TermInfo
  prepend TermInfoAdditions
end