require_dependency YourPlatform::Engine.root.join('app/models/term_reports/for_corporation').to_s

module TermReportAdditions

  def fill_info
    super
    self.anzahl_aktivmeldungen = number_of_new_members
    self.anzahl_aller_aktiven = corporation.aktivitas.member_count(at: end_of_term)
    self.anzahl_burschungen = anzahl_neue BURSCHEN_GROUP_NAMES
    self.anzahl_burschen = anzahl BURSCHEN_GROUP_NAMES
    self.anzahl_fuxen = anzahl FUXEN_GROUP_NAMES
    self.anzahl_aktiver_burschen = anzahl AKTIVE_BURSCHEN_GROUP_NAMES
    self.anzahl_inaktiver_burschen_loci = anzahl INAKTIVE_LOCI_GROUP_NAMES
    self.anzahl_inaktiver_burschen_non_loci = anzahl INAKTIVE_NON_LOCI_GROUP_NAMES
    self.anzahl_konkneipwanten = anzahl KONKNEIPANTEN_GROUP_NAMES
    self.anzahl_philistrationen = corporation.philisterschaft.new_member_count(during: term_time_range)
    self.anzahl_philister = corporation.philisterschaft.member_count(at: end_of_term)
    self.anzahl_austritte = number_of_membership_ends
    new_former_members = User.where(id: corporation.former_members_parent.new_member_ids(during: term_time_range))
    self.anzahl_austritte_aktive = new_former_members.select { |user| not user.ancestor_group_ids.include? Group.alle_philister.id }.count
    self.anzahl_austritte_philister = new_former_members.select { |user| user.ancestor_group_ids.include? Group.alle_philister.id }.count
    self.anzahl_todesfaelle = number_of_deaths
    self.anzahl_erstbandtraeger_aktivitas = erstbandtraeger_der_aktivitas.count
    self.anzahl_erstbandtraeger_philisterschaft = erstbandtraeger_der_philisterschaft.count
    self.save

    self.member_entries.destroy_all
    if term.kind_of?(Terms::Summer) or term.kind_of?(Terms::Winter)
      create_member_entries_for HOSPITANTEN_GROUP_NAMES
      create_member_entries_for FUXEN_GROUP_NAMES
      create_member_entries_for AKTIVE_BURSCHEN_GROUP_NAMES
      create_member_entries_for INAKTIVE_LOCI_GROUP_NAMES
      create_member_entries_for INAKTIVE_NON_LOCI_GROUP_NAMES
      create_member_entries_for KONKNEIPANTEN_GROUP_NAMES
    end

    return self
  end

  #Anzahl Amtsträger
  ## Anzahl Kalender-Abonnenten

  def anzahl(group_names)
    corporation.sub_group(group_names).member_count(at: end_of_term)
  end

  def anzahl_neue(group_names)
    corporation.sub_group(group_names).new_member_count(during: term_time_range)
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

  def member_ids(group_names)
    if corporation.sub_group(group_names)
      corporation.sub_group(group_names).memberships.at_time(end_of_term).order(:valid_from).map(&:user_id)
    else
      []
    end
  end

  def members(group_names)
    User.where id: member_ids(group_names)
  end

  def create_member_entries_for(group_names)
    members(group_names).each do |user|
      self.member_entries.create_from_user(user, category: group_names.first)
    end
  end


  def hospitanten
    members HOSPITANTEN_GROUP_NAMES
  end

  def fuxen
    members FUXEN_GROUP_NAMES
  end

  def aktive_burschen
    members AKTIVE_BURSCHEN_GROUP_NAMES
  end

  def inaktive_burschen_loci
    members INAKTIVE_LOCI_GROUP_NAMES
  end

  def inaktive_burschen_non_loci
    members INAKTIVE_NON_LOCI_GROUP_NAMES
  end

  def konkneipanten
    members KONKNEIPANTEN_GROUP_NAMES
  end

  def erstbandtraeger_der_aktivitas
    members(AKTIVITAS_GROUP_NAMES).select { |user| user.primary_corporation(at: end_of_term).id == corporation.id }
  end

  def erstbandtraeger_der_philisterschaft
    members(PHILISTERSCHAFT_GROUP_NAMES).select { |user| user.primary_corporation(at: end_of_term).id == corporation.id }
  end


  def over_due_at
    if term.kind_of? Terms::Summer
      Time.zone.now.change(year: year, month: 11, day: 5).to_date
    elsif term.kind_of? Terms::Winter
      Time.zone.now.change(year: year + 1, month: 5, day: 5).to_date
    end
  end

end

class TermReports::ForCorporation
  include GroupNameConstants

  prepend TermReportAdditions
end