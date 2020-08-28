# -*- coding: utf-8 -*-

# This extends the your_platform Group model.
require_dependency YourPlatform::Engine.root.join( 'app/models/group' ).to_s

# This class represents a group of the platform.
# While the most part of the group class is contained in the your_platform engine,
# this re-opened class contains all wingolf-specific additions to the group model.

class Group
  include GroupNameConstants

  # See also: `important_offiers`
  def important_officers_keys
    [:senior, :fuxmajor, :kneipwart, :phil_x, :kassenwart]
  end

  # Mailing lists
  #
  alias_method :original_mailing_list_sender_filter_settings, :mailing_list_sender_filter_settings
  def mailing_list_sender_filter_settings
    [:wingolfiten] + original_mailing_list_sender_filter_settings
  end

  alias_method :original_user_matches_mailing_list_sender_filter?, :user_matches_mailing_list_sender_filter?
  def user_matches_mailing_list_sender_filter?(user)
    case self.mailing_list_sender_filter.to_s
    when 'wingolfiten'
      user.wingolfit?
    else
      original_user_matches_mailing_list_sender_filter?(user)
    end
  end

  # Group exports
  #
  def self.export_list_presets
    super + [
      :stammdaten,
      :wingolfsblaetter
    ]
  end

  def export_stammdaten_list
    ListExports::Stammdaten.from_group(self)
  end

  def export_wingolfsblaetter_list
    ListExports::Wingolfsblaetter.from_group(self)
  end

  def list_export_by_preset(preset, options = {})
    case preset.to_s
    when 'stammdaten'
      self.export_stammdaten_list
    when 'wingolfsblaetter'
      self.export_wingolfsblaetter_list
    else
      super
    end
  end


  # Special Groups
  # ==========================================================================================

  def self.main_org
    self.alle_wingolfiten
  end


  # BVs
  # ------------------------------------------------------------------------------------------

  def self.find_bvs_parent_group
    find_special_group(:bvs_parent)
  end

  def self.create_bvs_parent_group
    bvs_parent_group = create_special_group(:bvs_parent, type: 'Groups::BvsParent')
    bvs_parent_group.parent_pages << Page.intranet_root
    return bvs_parent_group
  end

  def self.find_or_create_bvs_parent_group
    find_or_create_special_group(:bvs_parent)
  end

  def self.bvs_parent
    find_or_create_bvs_parent_group
  end

  def self.bvs_parent!
    find_bvs_parent_group || raise('special group :bvs_parent does not exist.')
  end

  def self.bvs
    self.find_bv_groups
  end

  def self.find_bv_groups
    (self.find_bvs_parent_group.try(:child_groups) || [])
  end

  def bv?
    Bv.find_bv_groups.include?(self)
  end

  # Wingolfsblätter-Abonnenten
  # ------------------------------------------------------------------------------------------

  def self.wbl_abo_group
    Group.find_by_flag(:wbl_abo)
  end

  def self.find_or_create_wbl_abo_group
    if self.wbl_abo_group
      return self.wbl_abo_group
    else
      wbl_page = Page.find_by_title("Wingolfsblätter")
      wbl_page ||= Page.find_or_create_intranet_root.child_pages.create(title: "Wingolfsblätter")
      group = wbl_page.child_groups.where(name: "Abonnenten").first
      group ||= wbl_page.child_groups.create(name: "Abonnenten")
      group.add_flag :wbl_abo
      return group
    end
  end

  def self.wbl_abo
    self.find_or_create_wbl_abo_group
  end

  def self.wbl_abo!
    self.wbl_abo_group
  end

  # This returns whether the group is special.
  # This means that the group is special, e.g.
  # an officers group or a Wingolfsblätter-Abonnenten or
  # BV
  def is_special_group?
    self.has_flag?( :wbl_abo ) or
    self.has_flag?( :bvs_parent ) or
    self.has_flag?( :officers_parent ) or
    self.ancestor_groups.select do |ancestor|
      ancestor.has_flag?(:officers_parent)
    end.any? or
    self.ancestor_groups.select do |ancestor|
      ancestor.has_flag?(:bvs_parent)
    end.any?
  end


  def memberships_for_member_list
    memberships_including_members
  end

  def self.ak_internet
    self.flagged(:ak_internet).first
  end

  # Jeder
  #   |
  # Alle Wingolfiten
  #   |
  #   |---- Alle Aktiven
  #   |---- Alle Philister
  #   |
  #   |---- Alle Amtsträger
  #               |----------- Alle Verbindungsamtsträger
  #               |                          |----------- Alle Chargierten
  #               |                          |                   |---------- Alle Seniores
  #               |                          |                   |---------- Alle Fuxmajores
  #               |                          |                   |---------- Alle Kneipwarte
  #               |                          |                   |---------- + Bundeschargierte
  #               |                          |
  #               |                          |------- Alle Aktiven-Schriftwarte
  #               |                          |------- Alle Aktiven-Kassenwarte
  #               |                          |------- Alle Fuxen-Seniores
  #               |                          |------- Alle Aktiven-Administratoren
  #               |                          |------- + alle übrigen WV-Amtsträger
  #               |
  #               |----------- Alle PhV-Amtsträger
  #               |                      |------------- Alle Phil-x
  #               |                      |------------- Alle Phil-Schriftwarte
  #               |                      |------------- Alle Phil-Kassenwarte
  #               |                      |------------- Alle Phil-Administratoren
  #               |
  #               |----------- Alle BV-Amtsträger
  #               |                      |------------- Alle BV-Leiter
  #               |                      |------------- Alle BV-Schriftwarte
  #               |                      |------------- Alle BV-Kassenwarte
  #               |                      |------------- Alle BV-Administratoren
  #               |
  #               |----------- Alle Vorsitzenden (Seniores, Phil-x, BV-Leiter, Bundes-x, VAW-x)
  #               |----------- Alle Schriftwarte (Schriftwarte + Bundes-xx + GfdW)
  #               |----------- Alle Kassenwarte  (Kassenwarte + Bundes-xxx + GfdW)
  #               |
  #               |----------- Alle Administratoren
  #                                      |------------- Alle Korporationen-Administretoren
  #                                      |------------- Alle Aktiven-Administratoren
  #                                      |------------- Alle Phil-Administratoren
  #                                      |------------- Alle BV-_Administratoren
  #
  #
  def self.alle_wingolfiten
    @alle_wingolfiten ||= self.find_or_create_special_group :alle_wingolfiten
  end
  def self.alle_aktiven
    self.find_or_create_special_group :alle_aktiven
  end
  def self.alle_philister
    self.find_or_create_special_group :alle_philister
  end
  def self.alle_verstorbenen_wingolfiten
    self.find_or_create_by name: "Alle Verstorbenen Wingolfiten"
  end
  def self.alle_amtstraeger
    alle_wingolfiten.find_or_create_special_group :alle_amtstraeger
  end
  def self.alle_wv_amtstraeger
    alle_amtstraeger.find_or_create_special_group :alle_wv_amtstraeger
  end
  def self.alle_phv_amtstraeger
    alle_amtstraeger.find_or_create_special_group :alle_phv_amtstraeger
  end
  def self.alle_bv_amtstraeger
    alle_amtstraeger.find_or_create_special_group :alle_bv_amtstraeger
  end
  def self.alle_vorsitzenden
    alle_amtstraeger.find_or_create_special_group :alle_vorsitzenden
  end
  def self.alle_schriftwarte
    alle_amtstraeger.find_or_create_special_group :alle_schriftwarte
  end
  def self.alle_kassenwarte
    alle_amtstraeger.find_or_create_special_group :alle_kassenwarte
  end
  def self.alle_chargierten
    alle_wv_amtstraeger.find_or_create_special_group :alle_chargierten
  end
  def self.alle_seniores
    alle_chargierten.find_or_create_special_group :alle_seniores
  end
  def self.alle_fuxmajores
    alle_chargierten.find_or_create_special_group :alle_fuxmajores
  end
  def self.alle_kneipwarte
    alle_chargierten.find_or_create_special_group :alle_kneipwarte
  end
  def self.alle_wv_schriftwarte
    alle_wv_amtstraeger.find_or_create_special_group :alle_wv_schriftwarte
  end
  def self.alle_wv_kassenwarte
    alle_wv_amtstraeger.find_or_create_special_group :alle_wv_kassenwarte
  end
  def self.alle_fuxen_seniores
    alle_wv_amtstraeger.find_or_create_special_group :alle_fuxen_seniores
  end
  def self.alle_phv_vorsitzende
    alle_phv_amtstraeger.find_or_create_special_group :alle_phv_vorsitzende
  end
  def self.alle_phv_schriftwarte
    alle_phv_amtstraeger.find_or_create_special_group :alle_phv_schriftwarte
  end
  def self.alle_phv_kassenwarte
    alle_phv_amtstraeger.find_or_create_special_group :alle_phv_kassenwarte
  end
  def self.alle_bv_leiter
    alle_bv_amtstraeger.find_or_create_special_group :alle_bv_leiter
  end
  def self.alle_bv_schriftwarte
    alle_bv_amtstraeger.find_or_create_special_group :alle_bv_schriftwarte
  end
  def self.alle_bv_kassenwarte
    alle_bv_amtstraeger.find_or_create_special_group :alle_bv_kassenwarte
  end
  def self.alle_administratoren
    alle_amtstraeger.find_or_create_special_group :alle_administratoren
  end
  def self.alle_korporationen_administratoren
    alle_administratoren.find_or_create_special_group :alle_korporationen_administratoren
  end
  def self.alle_wv_administratoren
    alle_administratoren.find_or_create_special_group :alle_wv_administratoren
  end
  def self.alle_phv_administratoren
    alle_administratoren.find_or_create_special_group :alle_phv_administratoren
  end
  def self.alle_bv_administratoren
    alle_administratoren.find_or_create_special_group :alle_bv_administratoren
  end

end

