# This extends the your_platform User model.
require_dependency YourPlatform::Engine.root.join( 'app/models/user' ).to_s

# This class represents a user of the platform. A user may or may not have an account.
# While the most part of the user class is contained in the your_platform engine,
# this re-opened class contains all wingolf-specific additions to the user model.
#
module UserOverrides

  def summary_components
    hash = super
    hash[:name_affix] = "(#{aktivitaetszahl_in_vademecum_format})"
    hash
  end

  def default_avatar_path
    if wingolfit?
      "https://github.com/fiedl/wingolfsplattform/raw/master/app/assets/images/avatar_480.png"
    else
      super
    end
  end

end

class User
  prepend UserOverrides
  include UserLeibverhaeltnisse
  include UserNetenvData

  scope :wingolfiten, -> { includes(:groups).where(groups: {id: Group.alle_wingolfiten.id}) }

  def name_affix
    "#{aktivitaetszahl} #{string_for_death_symbol}".gsub("  ", " ").strip
  end

  def personal_greeting(options = {})
    if self.wingolfit?
      bbr = if self.aktiver?
        "Bundesbruder"
      else
        if options[:current_user] && options[:current_user].philister?
          "Conphilister"
        else
          "Philister"
        end
      end
      "Lieber #{bbr} #{self.last_name}"
    else
      super
    end
  end


  # This method returns the bv (Bezirksverband) the user is associated with.
  #
  def bv
    Bv.find(bv_id) if bv_id
  end
  def bv_ids
    # TODO: Sobald ActsAsDag obsolet ist, müssen nur noch direkte Mitgliedschaften
    # berücksichtigt werden. Im Moment ist aber noch ein "Hack" nötig, weil ActsAsDag
    # nicht damit klarkommt, dass man Amtsträger und direktes Mitglied in einem BV ist.
    # Der direkte BV soll aber Vorrang vor dem Amts-BV haben. Deshalb so umständlich.
    #
    # Nach der Umstellung wird es einfach:
    # # Bv.pluck(:id) & self.direct_group_ids

    ((Bv.pluck(:id) & self.direct_group_ids) + (Bv.pluck(:id) & self.group_ids)).uniq
  end
  def bv_id
    bv_ids.first
  end

  def bv_membership
    @bv_membership ||= Membership.find_by_user_and_group(self, bv) if bv
  end

  # Diese Methode gibt die BVs zurück, denen der Benutzer zugewiesen ist. In der Regel
  # ist jeder Philister genau einem BV zugeordnet. Durch Fehler kann es jedoch dazu kommen,
  # dass er mehreren BVs zugeordnet ist.
  #
  def bv_memberships
    bv_ids.collect do |id|
      Membership.find_by_user_and_group(self, Group.find(id))
    end - [nil]
  end

  def bv_beitrittsdatum
    bv_membership.valid_from if bv && bv_membership
  end

  # Diese Methode gibt den BV zurück, dem der Benutzer aufgrund seiner Postanschrift
  # zugeordnet sein sollte. Der eingetragene BV kann und darf davon abweisen, da er
  # in Sonderfällen auch händisch zugewiesen werden kann.
  #
  # Achtung: Nur Philister sind BVs zugeordnet. Wenn der Benutzer Aktiver ist,
  # gibt diese Methode `nil` zurück.
  #
  def correct_bv
    if self.philister?
      if primary_address_field.try(:value).try(:present?)
        primary_address_field.delete_cache
        primary_address_field.bv
      else
        # Wenn keine Adresse gegeben ist, in den BV 00 (Unbekannt Verzogen) verschieben.
        Bv.find_by_token("BV 00")
      end
    end
  end

  # Es gibt Philister, die einen Wunsch-BV haben, d.h. nicht ihrem eigentlichen
  # BV zugeordnet werden sollen, da sie lieber in einem anderen BV sind.
  #
  def wunsch_bv?
    manual_bv?
  end
  def manual_bv?
    member_of? (Group.flagged(:philister_mit_wunsch_bv).first || Group.where(name: 'Philister mit Wunsch-BV').first)
  end


  # Diese Methode passt den BV des Benutzers der aktuellen Postanschrift an.
  # Achtung: Nur Philister sind BVs zugeordnet. Wenn der Benutzer Aktiver ist,
  # tut diese Methode nichts.
  #
  def adapt_bv_to_primary_address
    self.groups.reload
    new_bv = correct_bv

    # Wenn der Philister einen Wunsch-BV hat, wird die automatische Zuordnung
    # nicht vorgenommen.
    #
    return false if wunsch_bv?

    # Fall 0: Es konnte kein neuer BV identifiziert werden.
    # In diesem Fall wird aus Konsistenzgründen die aktuelle BV-Mitgliedschaft
    # zurückgegeben, da der BV dann nicht verändert werden soll.
    #
    if not new_bv
      new_membership = self.bv_membership

    # Fall 1: Es ist noch kein BV zugewiesen. Es wird schlicht der neue zugewiesen.
    #
    elsif new_bv and not bv_membership
      new_membership = new_bv.assign_user self

    # Fall 2: Es ist bereits ein BV zugewiesen. Der neue BV ist auch der alte
    # BV. Die Mitgliedschaft muss also nicht geändert werden.
    #
    elsif new_bv and (new_bv == bv)
      new_membership = self.bv_membership

    # Fall 3: Es ist bereits ein BV zugewiesen. Der neue BV weicht davon ab.
    # Die Mitgliedschaft muss also geändert werden.
    #
    elsif new_bv and bv and (new_bv != bv)

      # FIXME: For the moment, DagLinks have to be unique. Therefore, the old
      # membership has to be destroyed if the user previously had been a member
      # of the new bv. When DagLinks are allowed to exist several times, remove
      # this hack:
      #
      if old_membership = Membership.now_and_in_the_past.find_by_user_and_group(self, new_bv)
        if old_membership != self.bv_membership
          old_membership.destroy
        end
      end

      new_membership = if self.bv_membership.try(:direct?)
        self.bv_membership.move_to new_bv
      else # Amtsträger nicht verschieben!
        self.bv_membership
      end
    end

    # Korrekturlauf: Durch einen Fehler kann es sein, dass ein Benutzer mehreren
    # BVs zugeordnet ist. Deshalb werden hier die übrigen BV-Mitgliedschaften
    # deaktiviert, damit er nur noch dem neuen BV zugeordnet ist.
    #
    for membership in self.bv_memberships
      membership.invalidate at: 1.minute.ago if membership != new_membership and membership.direct?
    end

    # Cache zurücksetzen
    self.delay.delete_cache
    #self.delay.delete_cached :bv
    #self.delay.delete_cached :bv_membership

    self.groups.reload
    return new_membership
  end

  # This method returns the aktivitaetszahl of the user, e.g. "E10 H12".
  #
  def aktivitaetszahl
    self.corporations
      .select { |corporation| role = Role.of(self).in(corporation); role.full_member? or role.deceased_member? }
      .collect { |corporation| {string: aktivitaetszahl_for(corporation), year: aktivitaetszahl_year_for(corporation)} }
      .sort_by { |hash| hash[:year] }  # Sort by the year of joining the corporation.
      .collect { |hash| hash[:string] }.join(" ")
  end

  def fruehere_aktivitaetszahl
    self.corporations
      .collect { |corporation| {string: aktivitaetszahl_for(corporation), year: aktivitaetszahl_year_for(corporation)} }
      .sort_by { |hash| hash[:year] }  # Sort by the year of joining the corporation.
      .collect { |hash| hash[:string] }.join(" ")
  end

  def aktivitätszahl
    aktivitaetszahl
  end

  def aktivitaetszahl_for(corporation)
    "#{corporation.token} #{aktivitaetszahl_addition_for(corporation)} #{aktivitaetszahl_short_year_for(corporation)}".gsub('  ', '').strip
  end

  def aktivitaetszahl_year_for(corporation)
    (corporation.status_groups.collect { |status_group| status_group.membership_of(self, also_in_the_past: true).try(:valid_from) } - [nil]).min.to_s[0, 4]
  end
  def aktivitaetszahl_short_year_for(corporation)
    aktivitaetszahl_year_for(corporation)[2, 2]
  end

  def aktivitaetszahl_addition_for(corporation)
    addition = ""
    addition += " Stft" if self.member_of? corporation.descendant_groups.find_by_name("Stifter"), also_in_the_past: true
    addition += " Nstft" if self.member_of? corporation.descendant_groups.find_by_name("Neustifter"), also_in_the_past: true
    addition += " Eph" if self.member_of? corporation.descendant_groups.find_by_name("Ehrenphilister"), also_in_the_past: true
    addition += " " if addition != ""
    return addition.strip
  end

  def aktivitaetszahl_in_vademecum_format
    aktivitaetszahl_in_format_mit_komma
  end

  def aktivitaetszahl_in_format_mit_halben_leerzeichen
    # Perfect regex tester: http://rubular.com
    aktivitaetszahl.gsub(/([A-Za-z]+)([0-9]+)/, '\1&thinsp;\2')
      .gsub(" Stft ", "&thinsp;Stft&thinsp;")
      .gsub(" Nstft ", "&thinsp;Nstft&thinsp;")
      .gsub(" Eph ", "&thinsp;Eph&thinsp;")
      .gsub("&thinsp;", " ")
  end
  def aktivitaetszahl_in_format_mit_komma
    aktivitaetszahl.gsub(" ", ", ").gsub(/([A-Za-z]+)([0-9]+)/, '\1 \2')
      .gsub(", Stft, ", " Stft ")
      .gsub(", Nstft, ", " Nstft ")
      .gsub(", Eph, ", " Eph ")
  end

  def klammerung
    self.profile_fields.where(label: :klammerung).first.try(:value)
  end

  def aktivmeldungsdatum
    status_memberships.with_past.order(:valid_from).first.try(:valid_from).try(:to_date)
  end
  def aktivmeldungsdatum=(date)
    status_memberships.with_past.order(:valid_from).first.update_attributes valid_from: date.to_datetime
  end


  # Fill-in default profile.
  #
  def fill_in_template_profile_information
    self.profile_fields.create(label: :personal_title, type: "ProfileFields::General")
    self.profile_fields.create(label: :academic_degree, type: "ProfileFields::AcademicDegree")
    self.profile_fields.create(label: :cognomen, type: "ProfileFields::General")
    self.profile_fields.create(label: :klammerung, type: "ProfileFields::Klammerung")

    self.profile_fields.create(label: :home_address, type: "ProfileFields::Address") unless self.home_address
    self.profile_fields.create(label: :work_or_study_address, type: "ProfileFields::Address") unless self.work_or_study_address
    self.profile_fields.create(label: :phone, type: "ProfileFields::Phone") unless self.phone.present?
    self.profile_fields.create(label: :mobile, type: "ProfileFields::Phone") unless self.mobile.present?
    self.profile_fields.create(label: :fax, type: "ProfileFields::Phone")
    self.profile_fields.create(label: :homepage, type: "ProfileFields::Homepage")

    if self.study_fields.count == 0
      pf = self.profile_fields.build(label: :study, type: "ProfileFields::Study")
      pf.becomes(ProfileFields::Study).save
    end

    self.profile_fields.create(label: :professional_category, type: "ProfileFields::ProfessionalCategory")
    self.profile_fields.create(label: :occupational_area, type: "ProfileFields::ProfessionalCategory")
    self.profile_fields.create(label: :employment_status, type: "ProfileFields::ProfessionalCategory")
    self.profile_fields.create(label: :languages, type: "ProfileFields::Competence")

    pf = self.profile_fields.where(type: "ProfileFields::BankAccount").first_or_create do |pf|
      pf.label = :bank_account
    end

    pf = self.profile_fields.create(label: :name_field_wingolfspost, type: "ProfileFields::NameSurrounding")
      .becomes(ProfileFields::NameSurrounding)
    pf.text_above_name = ""; pf.name_prefix = "Herrn"; pf.name_suffix = ""; pf.text_below_name = ""
    pf.save

    self.wingolfsblaetter_abo = true
  end


  # W-Nummer  (old uid)
  # ==========================================================================================

  def w_nummer
    self.profile_fields.where(label: "W-Nummer").first.try(:value)
  end
  def w_nummer=(str)
    field = profile_fields.where(label: "W-Nummer").first || profile_fields.create(type: 'ProfileFields::General', label: 'W-Nummer')
    field.update_attribute(:value, str)
    field.delete_cache
  end

  def self.find_by_w_nummer(wnr)
    ProfileField.where(label: "W-Nummer", value: wnr).last.try(:profileable)
  end


  # Wingolfit?
  # ==========================================================================================

  # This method checks whether the user classifies as wingolfit.
  #
  #   * Users who terminated their membership in wingolf are considered not to be wingolfit.
  #   * Users who died while being member are considered as wingolfit.
  #   * Users with hospitant status are considered as wingolfit.
  #   * Users with guest status are not considered as wingolfit.
  #
  # This all comes down to this:
  # A user is a wingolfit if he has an aktivitätszahl.
  #
  def wingolfit?
    philister? || aktiver?
  end

  def aktiver?
    Group.alle_aktiven.members.include? self
  end

  def philister?
    Group.alle_philister.members.include? self
  end

  def group_names
    self.groups.pluck(:name)
  end

  # Defines whether the user can be marked as deceased (by a workflow).
  #
  # Nur Wingolfiten dürfen als verstorben markiert werden, da wir davon ausgehen, dass
  # eine Mitgliedschaft im Wingolf durch Austritt endet. Doch auch verstorbene Wingolfiten
  # sind noch Wingoliten. Jeders Mitglied in unserer Verstorbenen-Gruppe ist also noch
  # Wingolift. Daher darf aus Konsistenzgründen für Nicht-Wingolfiten kein Tod eingetragen
  # werden.
  #
  def markable_as_deceased?
    alive? and wingolfit?
  end



  # Abo Wingolfsblätter
  # ==========================================================================================

  def wbl_abo_group
    Group.find_or_create_wbl_abo_group
  end
  private :wbl_abo_group

  def wingolfsblaetter_abo
    self.member_of? wbl_abo_group
  end
  def wingolfsblaetter_abo=(new_abo_status)
    if new_abo_status == true || new_abo_status == "true" || new_abo_status == "1"

      # Aufgrund des Reaktivierungs-Bugs muss die Mitgliedschaft gelöscht
      # wreden, sofern sie schon existiert.
      # FIXME Reaktivierungs-Bug.
      # Ticket: http://support.wingolfsplattform.org/tickets/7393
      Membership.with_past.find_by_user_and_group(self, wbl_abo_group).try(:destroy)

      wbl_abo_group.assign_user self
    elsif new_abo_status == false || new_abo_status == "false" || new_abo_status == "0"
      wbl_abo_group.unassign_user self
    end
  end


  # Besondere Admin-Hilfs-Methoden

  def administrated_aktivitates
    Role.of(self).administrated_aktivitates
  end

  # Damit können wir einen Benutzer in der Konsole schnell finden:
  #
  #   User.find("Max Schmidt")
  #   User.find(12)
  #
  def self.find(*args)
    if args.first.kind_of?(String) and args.first.include?(" ")
      User.find_all_by_identification_string(args.first).first
    else
      super(*args)
    end
  end

  # Damit können wir in der Konsole besondere Statusänderungen
  # schnell eintragen.
  #
  # Als Parameter wird der Name der Statusgruppe angegeben.
  # Gegebenenfalls muss man auch das Band noch mit angeben.
  #
  #   user.change_status "Konkneipanten"
  #   user.change_status "Konkneipanten", in: "Be"
  #   user.change_status "Konkneipanten", in: "Be", at: "13.02.2015"
  #
  def change_status(new_status, options = {})
    corporation_token = options[:in]
    corp = if self.current_corporations.count == 1
      print "Ignoriere :in-Option, da nur ein Band vorliegt.\n" if corporation_token
      self.current_corporations.first
    else
      Corporation.find_by_token(corporation_token || raise('Der Benutzer ist Mehrbandträger. Bitte Band mit "in: \'Be\'" angeben.')) || raise('Keine passende Verbindung gefunden.')
    end
    current_status_membership = self.current_status_membership_in(corp) || raise('Aktuelle Status-Gruppe nicht gefunden.')
    new_status_group = corp.status_group(new_status) || raise('Neue Status-Gruppe nicht gefunden.')

    if options[:at]
      date = options[:at].to_datetime || raise('Datum nicht gültig.')
      current_status_membership.move_to new_status_group, at: date
    else
      current_status_membership.move_to new_status_group
    end

    self.renew_cache
    self.status
  end

  # So können wir schnell den aktuellen Status in der Konsole abfragen.
  #
  #   user.status
  #
  def status
    status_memberships = []
    self.corporations.each do |c|
      print "#{c.name}\n".blue
      print " -> #{self.current_status_group_in(c).try(:name)}\n".green
      status_memberships << self.current_status_membership_in(c)
    end
    return status_memberships
  end

  def status_export_string
    self.corporations.collect do |corporation|
      if membership = self.current_status_membership_in(corporation)
        "#{membership.group.name.singularize} im #{corporation.name} seit #{I18n.localize(membership.valid_from.to_date) if membership.valid_from}"
      else
        ""
      end
    end.join("\n")
  end

  def studium_export_string
    self.profile_fields.where(type: "ProfileFields::Study").collect do |study|
      "Studium der #{study.subject} an der #{study.university} vom #{study.from} bis #{study.to}"
    end.join("\n")
  end

  def philistrationsdatum
    self.membership_in(Group.alle_philister).valid_from
  end

  # Wenn jemand schon Philister ist, aber vergessen wurde, ihn in allen Verbindungen
  # zu philistrieren, kann diese Wartungs-Methode verwendet werden.
  #
  def in_allen_verbindungen_philistrieren!
    raise "Noch kein Philister. Das geht nur, wenn er schon in einer Verbindung Philister ist." unless philistrationsdatum
    self.current_corporations.each do |corporation|
      unless self.member_of? corporation.philisterschaft
        status_group_ids_in_this_corporation = StatusGroup.find_all_by_group(corporation.aktivitas).map(&:id)
        current_status_group = self.groups.where(id: status_group_ids_in_this_corporation).first
        membership = Membership.find_by_user_and_group(self, current_status_group)
        aenderungsdatum = philistrationsdatum
        aenderungsdatum = membership.valid_from + 1.day if membership.valid_from > aenderungsdatum
        membership.move_to corporation.philisterschaft.leaf_groups.first, at: aenderungsdatum
      end
    end
  end


  # ## Firmenname
  #
  # YourPlatform erlaubt, per Zuweisung an `corporation_name` den Benutzer einer neuen Firma
  # (= Organisation, = Corporation) zuzuweisen. Wenn die Firma nicht existiert, wird sie erstellt.
  #
  # Siehe: https://github.com/fiedl/your_platform/blob/master/app/models/concerns/user_corporations.rb
  #
  # Damit wir keine Verbindungen on-the-fly erstellen, wird dies für die Wingolfsplattform
  # blockiert.
  #
  def corporation_name
    nil
  end
  def corporation_name=(new_name)
    raise 'We do not allow to create corporations on the fly in Wingolfsplattform.'
  end


  # Early-Access-Features
  # https://trello.com/c/o5m2FveV/1290-early-access
  #
  #
  def early_access?
    aktiver? || beta_tester? || mitglied_im_ak_internet? || global_admin? || has_flag?(:dummy)
  end

  def mitglied_im_ak_internet?
    self.groups.include? Group.ak_internet
  end
  def ak_internet?
    mitglied_im_ak_internet?
  end



  if use_caching?
    cache :aktivitaetszahl
    cache :fruehere_aktivitaetszahl
    cache :name_affix
    cache :title
    cache :w_nummer
    cache :aktiver?
    cache :philister?
    cache :administrated_aktivitates
    cache :status_export_string
    cache :early_access?
  end

end

