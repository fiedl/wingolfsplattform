require_dependency YourPlatform::Engine.root.join('app/models/term_reports/for_corporation').to_s

module TermReportAdditions

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
    self.anzahl_erstbandtraeger_aktivitas = erstbandtraeger_der_aktivitas.count
    self.anzahl_erstbandtraeger_philisterschaft = erstbandtraeger_der_philisterschaft.count
    self.save

    self.member_entries.destroy_all
    if term.kind_of?(Terms::Summer) or term.kind_of?(Terms::Winter)
      create_member_entries_for "Hospitanten"
      create_member_entries_for "Fuxen"
      create_member_entries_for "Aktive Burschen"
      create_member_entries_for "Inaktive Burschen loci"
      create_member_entries_for "Inaktive Burschen non loci"
      create_member_entries_for "Konkneipanten"
    end

    return self
  end

  #Anzahl Amtsträger
  ## Anzahl Kalender-Abonnenten

  def anzahl(group_name)
    corporation.sub_group(group_name).memberships.at_time(end_of_term).count
  end

  def anzahl_neue(group_name)
    corporation.sub_group(group_name).memberships.where(valid_from: term_time_range).count
  end

  def senior
    officer(:senior)
  end

  def fuxmajor
    officer(:fuxmajor)
  end

  def kneipwart
    officer(:kneipwart)
  end

  def philister_x
    officer(:phil_x)
  end

  def kassenwart
    officer(:kassenwart)
  end

  def member_ids(group_name)
    Rails.cache.fetch [self.cache_key, "member_ids", group_name] do
      if corporation.sub_group(group_name)
        corporation.sub_group(group_name).memberships.at_time(end_of_term).order(:valid_from).map(&:user_id)
      else
        []
      end
    end
  end

  def members(group_name)
    User.where id: member_ids(group_name)
  end

  def create_member_entries_for(group_name)
    members(group_name).each do |user|
      self.member_entries.create_from_user(user, category: group_name)
    end
  end


  def hospitanten
    members "Hospitanten"
  end

  def fuxen
    members "Fuxen"
  end

  def aktive_burschen
    members "Aktive Burschen"
  end

  def inaktive_burschen_loci
    members "Inaktive Burschen loci"
  end

  def inaktive_burschen_non_loci
    members "Inaktive Burschen non loci"
  end

  def konkneipanten
    members "Konkneipanten"
  end

  def erstbandtraeger_der_aktivitas
    members("Aktivitas").select { |user| user.primary_corporation(at: end_of_term).id == corporation.id }
  end

  def erstbandtraeger_der_philisterschaft
    (members("Philisterschaft") + members("Altherrenschaft")).select { |user| user.primary_corporation(at: end_of_term).id == corporation.id }
  end

end

class TermReports::ForCorporation
  prepend TermReportAdditions
end