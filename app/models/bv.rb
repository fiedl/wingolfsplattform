class Bv < Group
  after_save { Bv.bvs_parent << self }
  
  def self.by_plz( plz )
    bv_token = BvMapping.find_by_plz( plz ).bv_name if BvMapping.find_by_plz( plz )
    bv_group = ( Bv.all.select { |group| group.token == bv_token } ).first if bv_token
    return bv_group.becomes Bv if bv_group
  end

  def self.by_address( address )
    self.by_country_code_and_plz address.country_code, address.plz
  end

  def self.by_geo_location( geo_location )
    self.by_country_code_and_plz geo_location.country_code, geo_location.plz
  end
  
  def self.by_country_code_and_plz(country_code, plz)
    country_code = country_code.upcase

    # Germany: Use PLZ to identify BV
    return self.by_plz(plz) if country_code == "DE"

    # Austria => BV 43
    return self.find_by_token("BV 43") if country_code == "AT"

    # Estonia => BV 44
    return self.find_by_token("BV 44") if country_code == "EE"

    # Rest of Europe => BV 45
    return self.find_by_token("BV 45") if country_code.in? GeoLocation.european_country_codes

    # Rest of the World => BV 46
    return self.find_by_token("BV 46") if country_code.present?

    # No valid address given => BV 00
    return self.find_by_token("BV 00")
  end


  # Ordnet den +user+ diesem BV zu und trägt ihn ggf. aus seinem vorigen BV aus.
  #
  def assign_user( user, options = {} )
    Bv.unassign_user user
    super(user, options)

    # TODO: Hier muss noch der entsprechende Workflow später getriggert werden, 
    # damit die automatischen Benachrichtigungen versandt werden.
  end

  # Trägt einen Benutzer aus seinem eigenen BV aus.
  def self.unassign_user( user )
    old_bv = user.bv
    old_bv.try(:unassign_user, user)
  end

end
