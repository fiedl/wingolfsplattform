require File.join(Rails.root, 'app/models/user')

class User
  
  # Allgemeine Attribute
  # =======================================================================
    
  # Grundlegende Attribute übernehmen, die zur Erstellung eines
  # Datensatzes notwendig sind.
  #
  # Vor- und Zuname, E-Mail-Adresse, Alias, W-Nummer, Geburtsdatum.
  # 
  def import_basic_attributes_from( netenv_user )
    self.first_name = netenv_user.first_name
    self.last_name = netenv_user.last_name
    self.email = netenv_user.email
    self.alias = netenv_user.alias || netenv_user.w_nummer
    self.save!
    self.date_of_birth = netenv_user.date_of_birth
    self.add_profile_field 'W-Nummer', value: netenv_user.w_nummer, type: 'General' 
  end
  
  def import_timestamps_from( netenv_user )
    User.record_timestamps = false
    self.updated_at = netenv_user.updated_at
    self.created_at = netenv_user.created_at
    self.save
    User.record_timestamps = true
  end
  
  
  # Profilfelder
  # =======================================================================
    
  def import_general_profile_fields_from( netenv_user )
    # Name, Geburtsdatum bereits importiert.
    add_profile_field :former_name, value: netenv_user.former_name, type: 'General'
    add_profile_field :personal_title, value: netenv_user.personal_title, type: 'General', force: true
    add_profile_field :academic_degree, value: netenv_user.academic_degree, type: 'General', force: true
    add_profile_field :cognomen, value: netenv_user.cognomen, type: 'General', force: true
    add_profile_field :klammerung, value: netenv_user.klammerung, type: 'General', force: true
  end

  def import_contact_profile_fields_from( netenv_user )
    add_profile_field :home_email, value: netenv_user.home_email, type: 'Email' unless netenv_user.home_email == netenv_user.email
    add_profile_field :work_email, value: netenv_user.work_email, type: 'Email' unless netenv_user.work_email == netenv_user.email
    add_profile_field netenv_user.home_address_label, value: netenv_user.home_address, type: 'Address'
    add_profile_field netenv_user.work_address_label, value: netenv_user.work_address, type: 'Address'
    add_profile_field :home_phone, value: netenv_user.home_phone, type: 'Phone'
    add_profile_field :work_phone, value: netenv_user.work_phone, type: 'Phone'
    add_profile_field :mobile, value: netenv_user.mobile, type: 'Phone'
    add_profile_field :home_fax, value: netenv_user.home_fax, type: 'Phone'
    add_profile_field :work_fax, value: netenv_user.work_fax, type: 'Phone'
    add_profile_field :homepage, value: netenv_user.homepage, type: 'Homepage'
    add_profile_field :work_homepage, value: netenv_user.work_homepage, type: 'Homepage'
  end

  def import_study_profile_fields_from( netenv_user )
    if netenv_user.erstes_fachsemester == netenv_user.erstes_studiensemester
      if netenv_user.erstes_fachsemester.present?
        add_profile_field :study, from: netenv_user.erstes_studiensemester, subject: "Studium #{netenv_user.educational_area}", type: 'Study'
      end
    else
      add_profile_field :study, from: netenv_user.erstes_studiensemester, subject: "", type: 'Study'
      add_profile_field :further_study, from: netenv_user.erstes_fachsemester, subject: "Studium #{netenv_user.educational_area}", type: 'Study'
    end
  end
  
  def import_professional_profile_fields_from( netenv_user )
    
    # Beschäftigungsstatus
    add_profile_field :employment_status, value: netenv_user.employment_status, type: 'ProfessionalCategory'
    
    # Amtsbezeichnung
    add_profile_field :employment_title, value: netenv_user.employment_title, type: 'ProfessionalCategory'
    
    # Berufsgruppen
    label = ( netenv_user.professional_categories.count > 1 ? :professional_categories : :professional_category )
    add_profile_field label, value: netenv_user.professional_categories.join(", "), type: 'ProfessionalCategory'
    
    # Tätigkeitsbereiche
    label = ( netenv_user.occupational_areas.count > 1 ? :occupational_areas : :occupational_area )
    add_profile_field label, value: netenv_user.occupational_areas.join(", "), type: 'ProfessionalCategory'
    
    # Tätigkeit (Freitext)
    add_profile_field :activity, value: netenv_user.activity_freetext, type: 'ProfessionalCategory'
    
    # Sprachen
    netenv_user.native_languages.each do |language|
      add_profile_field :native_language, value: language, type: 'Competence'
    end
    netenv_user.language_skills.each do |language|
      add_profile_field :language, value: language, type: 'Competence'
    end
    
    # Berufliche Erfahrung als: Berufsberater, Entwickler, Projektleiter
    netenv_user.professional_experiences.each do |experience|
      add_profile_field :experience_as, value: experience, type: 'Competence'
    end
    
    # Weitere Fertigkeiten
    netenv_user.general_skills.each do |skill|
      add_profile_field :skill, value: skill, type: 'Competence'
    end
    
    # Angebote
    netenv_user.offerings.each do |offering|
      add_profile_field :i_offer, value: offering, type: 'Competence'
    end
    add_profile_field :i_offer_talk_about, value: netenv_user.offering_talk_about, type: 'Competence'  # Vortrag zum Thema
    add_profile_field :i_offer_training, value: netenv_user.offering_training, type: 'Competence'  # Praktika
    add_profile_field :i_offer, value: netenv_user.offering_freetext, type: 'Competence'
    
    # Gesuche
    netenv_user.requests.each do |request|
      add_profile_field :request, value: "Ich suche: #{request}", type: 'Competence'
    end
    add_profile_field :request, value: netenv_user.request_freetext, type: 'Competence'
    
  end
  
  def import_bank_profile_fields_from( netenv_user )
    add_profile_field :bank_account, netenv_user.bank_account.merge({ type: 'BankAccount' })
  end
  
  def import_communication_profile_fields_from( netenv_user )
    
    # Wingolfsblätter ja/nein
    self.wingolfsblaetter_abo = netenv_user.wbl_abo?
    
    # Namensfeld für Wingolfspost
    add_profile_field :name_field_wingolfspost, text_above_name: netenv_user.text_above_name, name_prefix: netenv_user.name_prefix, name_suffix: netenv_user.name_suffix, text_below_name: netenv_user.text_below_name, type: 'NameSurrounding'

  end
  
  def add_profile_field( label, args )
    raise 'no :type argument given' unless args[:type].present?
    args[:type] = "ProfileFieldTypes::#{args[:type]}" unless args[:type].start_with? "ProfileFieldTypes::"
    if (args[:force] or one_argument_present?(args))
      args.delete(:force)
      if not profile_field_exists?(label, args)
        self.profile_fields.create.import_attributes(args.merge( { label: label } ))
      end
    end
  end

  def one_argument_present?( args )
    args.except(:type).each do |key, value|
      return true if value.present?
    end
    return false
  end
  private :one_argument_present?
  
  def profile_field_exists?( label, args )
    self.profile_fields.where(label: label, value: args[:value], type: args[:type]).count > 0
  end
  private :profile_field_exists?


  # Status: Hidden
  # =======================================================================

  def import_hidden_status_from( netenv_user )
    self.hidden = true if netenv_user.hidden?
  end
  
  
  # Mitgliedschaft in Korporationen
  # =======================================================================
  
  def import_corporation_memberships_from( netenv_user )
    reset_corporation_memberships
    import_primary_corporation_from netenv_user
    import_secondary_corporations_from netenv_user
    import_stifter_status_from netenv_user
    import_exit_events_from netenv_user
    import_death_from netenv_user
  end
  
  def reset_corporation_memberships
    (self.parent_groups & Group.corporations_parent.descendant_groups).each do |group|
      UserGroupMembership.with_invalid.find_by_user_and_group(self, group).destroy      
    end
  end
  
  def import_primary_corporation_from( netenv_user )
    corporation = netenv_user.primary_corporation
    
    if netenv_user.ehrenphilister?(corporation)
      
      # Ehrenphilister
      ehrenphilister = corporation.status_group("Ehrenphilister")
      membership_ehrenphilister = ehrenphilister.assign_user self, at: netenv_user.aktivmeldungsdatum
      
    else
    
      # Aktivmeldung
      raise 'no aktivmeldungsdatum given.' unless netenv_user.aktivmeldungsdatum
      hospitanten = corporation.status_group("Hospitanten")
      membership_hospitanten = hospitanten.assign_user self, at: netenv_user.aktivmeldungsdatum
     
      # Reception
      if netenv_user.receptionsdatum
        krassfuxen = corporation.status_group("Kraßfuxen")
        membership_krassfuxen = membership_hospitanten.promote_to krassfuxen, at: netenv_user.receptionsdatum
      end
      
      # Burschung
      if netenv_user.burschungsdatum
        burschen = corporation.status_group("Aktive Burschen")
        current_membership = self.reload.current_status_membership_in corporation
        membership_burschen = current_membership.promote_to burschen, at: netenv_user.burschungsdatum
      end
     
      # Philistration
      if netenv_user.philistrationsdatum
        philister = corporation.status_group("Philister")
        current_membership = self.reload.current_status_membership_in corporation
        membership_philister = current_membership.promote_to philister, at: netenv_user.philistrationsdatum
      end
      
    end
  end
  
  def import_secondary_corporations_from( netenv_user )

    last_date_of_joining = netenv_user.aktivmeldungsdatum
    
    netenv_user.secondary_corporations.each do |corporation|

      # Wenn zwei Bandaufnahmen im gleichen Jahr sind, aber nicht bekannt ist, an welchem Datum
      # sie jeweils stattfanden, muss trotzdem die Reihenfolge der Bandaufnahmen berücksichtigt
      # werden. Also wird jeweils verglichen, ob das die nächste Bandaufnahme im gleichen Jahr
      # war wie die vorige und dann im Zweifel ein Tag zum angenommenen Datum dazugezählt, damit
      # die Reihenfolge erhalten bleibt.
      #
      year_of_joining = netenv_user.year_of_joining(corporation)
      if last_date_of_joining.year.to_s == year_of_joining.to_s
        assumed_date_of_joining = last_date_of_joining + 1.day
      else
        assumed_date_of_joining = year_of_joining.to_datetime
      end
      last_date_of_joining = assumed_date_of_joining
      
      if netenv_user.bandaufnahme_als_aktiver?( corporation )
        group_to_assign = corporation.status_group("Aktive Burschen")
      elsif netenv_user.bandverleihung_als_philister?( corporation )
        group_to_assign = corporation.status_group("Philister")
      end
      
      if netenv_user.ehrenphilister?(corporation)
        group_to_assign = corporation.status_group("Ehrenphilister")
      end

      raise 'could not identify group to assign this user' if not group_to_assign
      group_to_assign.assign_user self, at: assumed_date_of_joining
    end
  end
  
  def import_stifter_status_from( netenv_user )
    netenv_user.corporations.each do |corporation|
      if netenv_user.stifter?(corporation)
        corporation.descendant_groups.find_by_name("Stifter").assign_user self, at: netenv_user.assumed_date_of_joining(corporation)
      end
      if netenv_user.neustifter?(corporation)
        corporation.descendant_groups.find_by_name("Neustifter").assign_user self, at: netenv_user.assumed_date_of_joining(corporation)
      end
    end
  end
  
  def import_exit_events_from( netenv_user )
    netenv_user.former_corporations.each do |corporation|
      
      reason = netenv_user.reason_for_exit(corporation)  || "ausgetreten"
      date = netenv_user.date_of_exit(corporation) || netenv_user.netenv_org_membership_end_date
      
      # Unassign user from previous groups in that corporation.
      (self.parent_groups & corporation.descendant_groups).each do |status_group|
        
        # Wenn kein Austrittsdatum vermerkt ist, wird das Datum der Statusgruppe übernommen.
        date ||= UserGroupMembership.with_invalid.find_by_user_and_group(self, status_group).try(:valid_from)

        status_group.unassign_user self, at: date
      end

      former_members_parent_group = corporation.child_groups.find_by_flag(:former_members_parent)
      if reason == "ausgetreten"
        group_to_assign = former_members_parent_group.child_groups.find_by_name("Schlicht Ausgetretene")
      elsif reason == "gestrichen"
        group_to_assign = former_members_parent_group.child_groups.find_by_name("Gestrichene")
      end
      
      # Assign user to new status group.
      group_to_assign.assign_user self, at: date
    end
  end
  
  def import_death_from( netenv_user )
    if netenv_user.verstorben?
      
      date_of_death = netenv_user.netenv_org_membership_end_date
      date_of_death ||= self.memberships.order(:valid_from).last.valid_from + 1.day
            
      # Aus allen Gruppen austragen, außer der 'hidden_users'-Gruppe.
      self.direct_groups.each do |group|
        unless group.has_flag? :hidden_users
          group.unassign_user self, at: date_of_death
        end
      end
      
      # In die Verstorbenen-Gruppen der Korporationen eintragen.
      #
      # Hier müssen die `corporations` von `netenv_user`, nicht von `self` 
      # abgefragt werden, da die Gruppen-Mitgliedschaften ja schon entwertet sind.
      #
      # Nicht in die Verstorbenen-Gruppen der Korporationen eintragen, aus denen
      # der Benutzer ausgetreten war. Wingolfit auf Lebenszeit ist man nur, 
      # wenn man nicht ausgetreten ist. Sonst wird auch die Aktivitätszahl
      # falsch berechnet.
      #
      netenv_user.current_corporations.each do |corporation|
        group_to_assign = corporation.child_groups.find_by_flag(:deceased_parent)
        group_to_assign.assign_user self, at: date_of_death
      end
      
      # Set global date_of_death field.
      self.set_date_of_death_if_unset(date_of_death)
    end
  end
  
end
