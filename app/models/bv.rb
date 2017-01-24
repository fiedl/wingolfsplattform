class Bv < Group
  after_save { Bv.bvs_parent << self }

  def self.by_town_and_plz(town, plz)
    town = Bv.modify_town_for_loopup(town) if town  # Klammern entfernen etc., z.B. "Halle (Saale)" -> "Halle"

    bv_tokens = BvMapping
      .where(plz: plz)
      .where('town LIKE ?', "#{town}%")  # z.B. für "Freiburg" in "Freiburg im Breisgau". Vor der Stadt darf aber nichts kommen: Sonst bekommt man Probleme mit "Neuendorf b. Elmshorn", das sonst auch für "Elmshorn" gehalten werden kann.
      .pluck(:bv_name).uniq
    #binding.pry if bv_tokens.count > 1
    raise("Der Wohnort '#{plz} #{town}' kann nicht eindeutig einem BV zugeordnet werden.") if bv_tokens.count > 1

    bv_token = bv_tokens.first
    Bv.where(token: bv_token).first
  end

  def self.by_address(address_string)
    geo_location = GeoLocation.find_or_create_by address: address_string
    self.by_geo_location(geo_location)
  end

  def self.by_address_field(address_field)
    self.by_country_code_and_town_and_plz address_field.country_code, address_field.city, address_field.plz
  end

  def self.by_geo_location( geo_location )
    self.by_country_code_and_town_and_plz geo_location.country_code, geo_location.city, geo_location.plz
  end

  def self.by_country_code_and_town_and_plz(country_code, town, plz)
    country_code = country_code.try(:upcase)

    # Deutschland: BV per Wohnort (`town`) identifizieren.
    #
    # Derzeit wird die PLZ auf Wunsch von Neusel nicht berücksichtigt.
    #   Trello: https://trello.com/c/GynIkAfo/945
    #   Ticket: http://support.wingolfsplattform.org/tickets/500
    #
    return self.by_town_and_plz(town, plz) if country_code == "DE"

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


  def self.modify_town_for_loopup(town)
    if town
      town = town.gsub(/\(.*\)/, "").strip if town  # Klammern entfernen, z.B. "Halle (Saale)" -> "Halle"
      town = town.gsub("Munich", "München")
      town = town.gsub("Cologne", "Köln")
      town = town.gsub("Nuremberg", "Nürnberg")
      town = town.gsub("Brunswick", "Braunschweig")
      town = town.gsub("Giessen", "Gießen")
    end
    return town
  end

end
