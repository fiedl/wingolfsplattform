# -*- coding: utf-8 -*-
require 'importers/importer'

#
# This file contains the code to import users from the netenviron csv export.
# Import users like this:
#
#   require 'importers/user_import'
#   importer = UserImporter.new( file_name: "path/to/csv/file", filter: { "uid" => "W51061" },
#                                update_policy: :update )
#   importer.import
#   User.all  # will list all users
#
class UserImporter < Importer
  def initialize( args = {} )
    super(args)
    @object_class_name = "User"
  end

  def import
    import_file = ImportFile.new( file_name: @file_name, data_class_name: "UserData" )
    import_file.each_row do |user_data|
      if user_data.match?(@filter) 
        handle_dummies(user_data) do
          handle_deleted(user_data) do
            handle_existing(user_data) do |user|
              handle_existing_email(user_data) do |email_warning|
                user.update_attributes( user_data.attributes )
                user.save
                user.import_profile_fields( user_data.profile_fields_array, update_policy)
                user.handle_primary_corporation( user_data, progress )
                user.handle_corporations( user_data )
                user.handle_netenviron_status( user_data.netenviron_status )
                user.handle_former_corporations( user_data )
                user.handle_deceased( user_data )
                user.assign_to_groups( user_data.groups )
                progress.log_success unless email_warning
              end
            end
          end
        end
      end
    end
    progress.print_status_report
  end

  private

  # Ignore old dummy users from netenviron database.
  #
  def handle_dummies( data, &block ) 
    if data.netenviron_aktivitaetszahl.in? ["?????", "02", "03", "234", "VAW", "wingolf 00", "Wingolf 06", "wingolf 07"]
      warning = { message: "Ignoring dummy user #{data.w_nummer}.",
        user_uid: data.uid, name: data.name,
        aktivitaetszahl: data.netenviron_aktivitaetszahl
      }
      progress.log_ignore(warning)
    else
      yield
    end
  end

  def handle_deleted( data, &block )
    if data.netenviron_status == :deleted
      warning = { message: "Ignoring deleted user #{data.w_nummer}.",
        user_uid: data.uid, name: data.name }
      progress.log_ignore(warning)
    else
      yield
    end
  end

  def handle_existing_email( data, &block )
    if data.email_already_exists_for_other_user?
      warning = { message: "Email #{data.email} already exists. Keeping the existing one, ignoring the new one.",
        user_uid: data.uid, name: data.name }
      progress.log_warning(warning)
      data.email = nil
    end
    yield(warning)
  end

end

class String
  alias old_to_datetime to_datetime
  def to_datetime
    if (self[4..8] == "0000") || (self.length == 4)  # 20030000 || 2003
      str = self[0..3] + "-01-01" # 2003-01-01
      return str.to_datetime
    else
      old_to_datetime.in_time_zone
    end
  end
end

class UserData < ImportDataset

  def initialize( data_hash )
    super(data_hash)
    @object_class_name = "User"
    @profile_fields = []
  end

  def user_already_exists?
    self.already_imported?
  end
  
  # This looks for an object in the database that matches
  # the dataset to import. 
  #
  def already_imported_object  
    # User.where( first_name: self.first_name, last_name: self.last_name )
    #   .includes( :profile_fields )
    #   .select { |user| user.date_of_birth == self.date_of_birth }
    #   .first
    User.where( first_name: self.first_name, last_name: self.last_name )  # for better performance
    .select do |user|
      user.w_nummer == self.w_nummer
    end.first
  end
  
  def existing_user
    self.already_imported_object
  end

  def email_already_exists_for_other_user?
    return false if not self.email.present?
    if User.find_all_by_email( self.email ).count > 0 
      if user_already_exists?
        # Then the email address is the one of the user to import (update) now.
        # So, it's the same user.
        return false
      else
        # It's another user, therefore duplicate email!
        return true
      end
    end
  end

  def attributes
    {
      first_name:         self.first_name,
      last_name:          self.last_name,
      updated_at:         d('modifyTimestamp').to_datetime,
      created_at:         d('createTimestamp').to_datetime,
    }
  end

  def profile_fields_array
    add_profile_field 'W-Nummer', value: self.w_nummer, type: "General"

    add_profile_field :title, value: self.personal_title, type: "General"
    add_profile_field :date_of_birth, value: self.date_of_birth, type: "Date"

    add_profile_field :email, value: self.email, type: 'Email'
    add_profile_field :work_email, value: d('epdprofemailaddress'), type: 'Email'
    add_profile_field :home_email, value: d('epdprivateemailaddress'), type: 'Email'

    add_profile_field home_address_label, value: self.home_address, type: 'Address'
    add_profile_field professional_address_label, value: professional_address, type: 'Address'

    add_profile_field :home_phone, value: phone_format(d('homePhone')), type: 'Phone'
    add_profile_field :mobile, value: phone_format(d('mobile')), type: 'Phone'
    add_profile_field :home_fax, value: phone_format(d('epdpersonalfax')), type: 'Phone'
    add_profile_field :work_phone, value: phone_format(d('epdprofphone')), type: 'Phone'
    add_profile_field :work_fax, value: phone_format(d('epdproffax')), type: 'Phone'

    add_profile_field :homepage, value: d('epdpersonallabeledurl'), type: 'Homepage'
    add_profile_field :work_homepage, value: d('epdproflabeledurl'), type: 'Homepage'

    academic_degrees.each do |degree|
      add_profile_field :academic_degree, value: degree, type: "AcademicDegree"
    end

    add_profile_field :employment_title, value: employment_title, type: 'ProfessionalCategory'
    professional_categories.each do |category|
      add_profile_field :professional_category, value: category, type: 'ProfessionalCategory'
    end
    occupational_areas.each do |area|
      add_profile_field :occupational_area, value: area, type: 'ProfessionalCategory'
    end
    add_profile_field :employment_status, value: d('epdprofworktype'), type: 'ProfessionalCategory'
#    add_profile_field :employment, { type: 'Employment' }.merge(employment)

    add_profile_field :bank_account, bank_account.merge( { type: "BankAccount" } )

    @profile_fields
  end
  
  def add_profile_field( label, args )
    handle_existing_profile_field(label, args) do
      @profile_fields << args.merge( { label: label } ) if one_argument_present?(args)
    end
  end
  def one_argument_present?( args )
    args.except(:type).each do |key, value|
      return true if value.present?
    end
    return false
  end
  def profile_field_exists?( label, args )
    @profile_fields.include? args.merge( { label: label } )
  end
  def handle_existing_profile_field( label, args )
    # The update policy is handles outside this class. 
    # Here, we have just to make sure that the same profile field
    # is not created twice.
    #
    yield unless profile_field_exists?(label,args)
  end

  def phone_format( phone_number )
    ProfileFieldTypes::Phone.format_phone_number(phone_number) if phone_number
  end
  
  # TODO: WO EINFÜGEN?
  def contact_name
    
  end

  def home_address
    "#{d(:homePostalAddress)}\n" +
      "#{d(:epdpersonalpostalcode)} #{d(:epdpersonalcity)}\n" +
      "#{d(:epdcountry)}"
  end
  def home_address_label
    ( d('epdbuildingname') == "privat" ? nil : d('epdbuildingname') ) || :home_address
  end

  def professional_address
    "#{d(:epdprofaddress)}\n" +
      "#{d(:epdprofpostalcode)} #{d(:epdprofcity)}\n" +
      "#{d(:epdprofcountry)}"
  end
  def professional_address_label
    d('epdprofcompanyname') || ( aktiver? ? :study_address : :professional_address )
  end

  def employment_title # dt. Amtsbezeichnung
    d('epdwingolfprofamtsbezeichnung')
  end

#  def employment
#    { 
#      position: d("epdprofposition"),
#    }
#  end
  def professional_categories # dt. Berufsgruppen
    ( d('epdprofposition') ? d('epdprofposition') : "" ).split("|")
  end

  def occupational_areas # dt. Berufsfelder
    ( d('epdprofbusinesscateogory') ? d('epdprofbusinesscateogory') : "" ).split("|") +
      ( d('epdproffieldofemployment') ? d('epdproffieldofemployment') : "" ).split("|")
  end

  def bank_account
    {
      :account_holder => d('epdbankaccountowner'),
      :account_number => d('epdbankaccountnr'), 
      :bank_code => d('epdbankid'),
      :credit_institution => d('epdbankinstitution'), 
      :iban => d('epdbankiban'), 
      :bic => d('epdbankswiftcode') 
    }
  end

  def aktiver?
    status == "Aktiver"
  end
  def philister?
    status == "Philister"
  end
  def ehemaliger?
    status == "Ehemaliger"
  end

  def deceased?
    d(:epdorgmembershipendreason) == "verstorben"
  end

  def ehemalige_netenviron_aktivitaetszahl
    d(:epdwingolfformeractivities)
  end

  def netenviron_aktivitaetszahl
    d(:epdwingolfactivity)
  end

  def aktivitaetszahl
    netenviron_aktivitaetszahl.gsub(" Eph ", "?Eph?").gsub(" Stft ", "?Stft?")
      .gsub(" Nstft ", "?Nstft?").gsub(" ", "").gsub(",", " ").gsub("?", " ")
  end

  def aktivitätszahl
    aktivitaetszahl
  end

  def corporations
    corporations_by_netenviron_aktivitaetszahl( self.netenviron_aktivitaetszahl )
  end

  def former_corporations
    corporations_by_netenviron_aktivitaetszahl( self.ehemalige_netenviron_aktivitaetszahl )
  end

  def corporations_by_netenviron_aktivitaetszahl( str ) 
    # str == "E 12, Fr NStft 13"
    if str.present?

      raise 'TODO: HANDLE (E 12)-TYPE AKTIVITÄTSZAHLEN' if str.start_with? "("

      corporation_tokens = str.gsub(" Eph", "").gsub(" Stft", "").gsub(" Nstft", "")
        .gsub(/[0-9 ]+/, "").gsub(" ", "").split(",") 
      corporations = corporation_tokens.collect do |token|
        Corporation.find_by_token(token) || raise("Corporation #{token} not found.")
      end
    else
      []
    end
  end

  def reason_for_exit( corporation = nil ) 
    # 31.12.2008 - ausgetreten - durch WV Bo|23.01.2009 - ausgetreten - durch WV Hm
    reason = description_of_exit(corporation).split(" - ").second
  end

  def date_of_exit( corporation = nil )
    # 31.12.2008 - ausgetreten - durch WV Bo|23.01.2009 - ausgetreten - durch WV Hm
    date = description_of_exit(corporation).split(" - ").first.to_datetime
  end

  def description_of_exit( corporation = nil )
    corporation ||= self.former_corporations.first
    # 07.06.2008 - Philistration - durch WV Hm|15.12.2010 - ausgetreten - durch WV Hm
    strs = self.descriptions
      .select{ |d| d.match(" #{corporation.token}$") }
      .select{ |d| d.include?("ausgetreten") || d.include?("gestrichen") }
    raise 'selection algorithm returnet non-uniqe result. please correct the algorithm for this case.' if strs.count > 1
    return strs.first
  end

  def descriptions 
    d(:description).split("|")
  end

  def netenviron_org_membership_end_date
    d(:epdorgmembershipenddate).to_datetime
  end
  
  def first_name
    d(:givenName)
  end
  def last_name
    d(:sn)
  end
  def name
    "#{first_name} #{last_name}"
  end

  def personal_title
    (( [ d('epdpersonaltitle') ] || [] ) + ( [ d('epdpersonalothertitle') ] || [] )).join(" ")
  end
  def academic_degrees
    (d('epdeduacademictitle') ? d('epdeduacademictitle') : "").split("|")
  end

  def uid
    d(:uid)
  end

  def email
    d(:mail)
  end
  def email=(email)
    @data_hash[:mail] = email
  end

  def date_of_birth
    d(:epdbirthdate).to_date
    #begin
    #rescue # wrong date format
    #raise ''
    #return nil
  end

  def alias
    d(:epdalias)
  end
  def username
    self.alias
  end

  def academic_title
    d(:epdeduacademictitle)
  end

  def w_nummer
    d(:uid)
  end

  def netenviron_status 
    d(:epdstatus).to_sym
  end

  def aktivmeldungsdatum
    if (d(:epdorgmembershipstartdate)) and (d(:epdwingolfmutterverbindaktivmeldung)) and 
        (d(:epdwingolfmutterverbindaktivmeldung) != d(:epdorgmembershipstartdate))
      raise 'netenviron data conflict: aktivmeldungsdatum and orgmembershipstart both given and unequal.'
    end
    (d(:epdorgmembershipstartdate) || d(:epdwingolfmutterverbindaktivmeldung)).to_datetime
  end
  
  def receptionsdatum
    d(:epdwingolfmutterverbindrezeption).try(:to_datetime)
  end

  def burschungsdatum
    d(:epdwingolfmutterverbindburschung).try(:to_datetime)
  end

  def philistrationsdatum
    d(:epdwingolfaktuelverbindphilistration).try(:to_datetime)
  end
  
  def aktivitaet_by_corporation( corporation )
    parts = netenviron_aktivitaetszahl.split(", ")
    parts.select { |part| part.start_with?(corporation.token + " ") }.first
  end
  def ehrenphilister?( corporation )
    aktivitaet_by_corporation(corporation).include? "Eph"
  end
  def stifter?( corporation )
    aktivitaet_by_corporation(corporation).include? "Stft"
  end
  def neustifter?( corporation )
    aktivitaet_by_corporation(corporation).include? "Nstft"
  end

  def bandaufnahme_als_aktiver?( corporation )
    return true if not philistrationsdatum
    raise 'Grenzfall!' if year_of_joining(corporation) == philistrationsdatum.year.to_s
    year_of_joining(corporation) < philistrationsdatum.year.to_s
  end

  def bandverleihung_als_philister?( corporation )
    return false if not philistrationsdatum
    raise 'Grenzfall!' if year_of_joining(corporation) == philistrationsdatum.year.to_s
    year_of_joining(corporation) > philistrationsdatum.year.to_s
  end

  def year_of_joining( corporation )
    raise 'no corporation given.' if not corporation
    aktivitaet = aktivitaet_by_corporation(corporation)
    yy = aktivitaet.match( "[0-9][0-9]" )[0]
    yyyy = yy_to_yyyy(yy).to_s
  end

  def yy_to_yyyy( yy )
    # born 1950
    # 61 -> 1861?  1961?  2061?
    #              ----
    [ "18#{yy}", "19#{yy}", "20#{yy}" ].each do |year|
      return year if year > self.date_of_birth.year.to_s
    end
  end

  # status returns one of these strings:
  #   "Aktiver", "Philister", "Ehemaliger"
  #
  def status
    d(:epdorgstatusofperson)
  end

  def groups
    ldap_group_string = d('epddynagroups') 
    ldap_group_string += "|" + d('epddynagroupsstatus') if d('epddynagroupsstatus')
    ldap_assignments = ldap_group_string.split("|")
    ldap_group_paths = []
    ldap_assignments.each do |assignment| # assignment = "o=asd,ou=def"
      ldap_group_path = []
      ldap_category_assignments = assignment.split(",")
      ldap_category_assignments.each do |category_assignment|
        ldap_category, ldap_group = category_assignment.split("=")
        #ldap_group_path << { ldap_category => ldap_group }
        ldap_group_path << ldap_group
      end
      ldap_group_paths << ldap_group_path
    end
    ldap_group_paths
  end

end



module UserImportMethods

  # The profile_fields_hash should look like this:
  #
  #   profile_fields_hash_array = [ { label: 'Work Address', value: "my work address...", type: "Address" },
  #                                 { label: 'Work Phone', value: "1234", type: "Phone" },
  #                                 { label: 'Bank Account', type: "BankAccount", account_number: "1234", iban: "567", ... },
  #                                 ... ]
  #
  def import_profile_fields( profile_fields_hash_array, update_policy )
    return nil if self.profile_fields.count > 0 && update_policy == :ignore
    self.profile_fields.destroy_all if update_policy == :replace
    profile_fields_hash_array.each do |profile_field_hash|
      unless profile_field_exists?(profile_field_hash)
        profile_field = self.profile_fields.build
        profile_field.import_attributes( profile_field_hash )
        profile_field.save
      end
    end
  end

  def profile_field_exists?( attrs )
    self.profile_fields.where( label: attrs[:label], value: attrs[:value] ).count > 0
  end

  def update_attributes( attrs )
    attrs.each do |key,value|
      self.send( "#{key}=", value )
    end
    self.save
  end

  def assign_to_groups( groups )
    p "TODO: GROUP ASSIGNMENT"
    p groups
    p "-----"
  end

  def handle_netenviron_status( status )
    self.hidden = true if status == :silent
    if status == :deleted
      raise 'trying to handle deleted user, but all deleted users should have been filtered out.' 
    end
  end

  def handle_deceased( user_data )
    if user_data.deceased?
      if self.corporations.count == 0
        raise 'the user has no corporations, yet. please handle_deceased after assigning the user to corporations.'
      end
      self.corporations.each do |corporation|
        group_to_assign = corporation.child_groups.find_by_flag(:deceased_parent)
        group_to_assign.assign_user self, joined_at: user_data.netenviron_org_membership_end_date
      end
    end
  end

  def handle_primary_corporation( user_data, progress )
    corporation = user_data.corporations.first
    
    # Aktivmeldung
    raise 'aktivmeldungsdatum not given' if not user_data.aktivmeldungsdatum
    hospitanten = corporation.descendant_groups.find_by_name("Hospitanten")
    membership_hospitant = hospitanten.assign_user self, joined_at: user_data.aktivmeldungsdatum
    
    # Reception
    if user_data.receptionsdatum
      if (user_data.philistrationsdatum) and (user_data.receptionsdatum > user_data.philistrationsdatum)
        warning = { message: 'inconsistent netenviron data: philistration before reception! ingoring reception.',
                    name: self.name, uid: user_data.w_nummer, 
                    philistrationsdatum: user_data.philistrationsdatum,
                    receptionsdatum: user_data.receptionsdatum }
        progress.log_warning(warning)
      else
        krassfuxen = corporation.descendant_groups.find_by_name("Kraßfuxen")
        membership_krassfux = membership_hospitant.promote_to krassfuxen, date: user_data.receptionsdatum
      end
    end
    
    # Burschung
    if user_data.burschungsdatum
      burschen = corporation.descendant_groups.find_by_name("Aktive Burschen")
      membership_burschen = self.reload.current_status_membership_in(corporation)
        .promote_to burschen, date: user_data.burschungsdatum
    end
    
    # Philistration
    if user_data.philistrationsdatum
      philister = corporation.descendant_groups.find_by_name("Philister")
      membership_philister = self.reload.current_status_membership_in(corporation)
        .promote_to philister, date: user_data.philistrationsdatum
    end
  end

  def handle_corporations( user_data )
    user_data.corporations.each do |corporation|
      year_of_joining = user_data.year_of_joining(corporation)
      group_to_assign = nil
      if user_data.aktivmeldungsdatum.year.to_s == year_of_joining
        # Already handled by #handle_primary_corporation.
      else
        date_of_joining = year_of_joining.to_datetime
        if user_data.bandaufnahme_als_aktiver?( corporation )
          group_to_assign = corporation.descendant_groups.find_by_name("Aktive Burschen")
        elsif user_data.bandverleihung_als_philister?( corporation )
          group_to_assign = corporation.descendant_groups.find_by_name("Philister")
        end
        
        if user_data.ehrenphilister?(corporation)
          group_to_assign = corporation.descendant_groups.find_by_name("Ehrenphilister")
        end

        raise 'could not identify group to assign this user' if not group_to_assign
        group_to_assign.assign_user self, joined_at: date_of_joining
        
        if user_data.stifter?(corporation)
          corporation.descendant_groups.find_by_name("Stifter").assign_user self, joined_at: date_of_joining
        end
        if user_data.neustifter?(corporation)
          corporation.descendant_groups.find_by_name("Neustifter").assign_user self, joined_at: date_of_joining
        end
        
      end
    end

    if user_data.aktivitaetszahl != self.reload.aktivitaetszahl
      raise "consistency check failed: aktivitaetszahl #{user_data.aktivitaetszahl} not reconstructed properly."
    end
  end

  def handle_former_corporations( user_data )
    user_data.former_corporations.each do |corporation|
      reason = user_data.reason_for_exit(corporation)
      date = user_data.date_of_exit(corporation)
      former_members_parent_group = corporation.child_groups.find_by_flag(:former_members_parent)
      if reason == "ausgetreten"
        group_to_assign = former_members_parent_group.child_groups.find_by_name("Schlicht Ausgetretene")
      elsif reason == "gestrichen"
        group_to_assign = former_members_parent_group.child_groups.find_by_name("Gestrichene")
      end
      
      group_to_assign.assign_user self, joined_at: date
    end
  end

end

User.send( :include, UserImportMethods )

module ProfileFieldImportMethods

  # The attr_hash to import should look like this:
  #
  #   attr_hash = { label: ..., value: ..., type: ... }
  #
  # Types are:
  #
  #   Address, Email, Phone, Custom
  #
  def import_attributes( attr_hash )
    if attr_hash && attr_hash.kind_of?( Hash ) &&
        attr_hash[:label].present? && attr_hash[:type].present? &&
        attr_hash.keys.count > 2 # label, type, and some form of value

      unless attr_hash[:type].start_with? "ProfileFieldTypes::"
        attr_hash[:type] = "ProfileFieldTypes::#{attr_hash[:type]}"
      end

      self.update_attributes( type: attr_hash[:type] )
      self.save

      # This is needed in order to have access to the methods
      # that depend on the type set above.
      #
      reloaded_self = ProfileField.find(self.id)

      attr_hash.each do |key,value|
        reloaded_self.send("#{key}=", value)
      end
      reloaded_self.save

    end
  end

end

ProfileField.send( :include, ProfileFieldImportMethods )

