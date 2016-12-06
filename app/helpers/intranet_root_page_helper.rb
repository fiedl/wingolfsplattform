module IntranetRootPageHelper

  def anzahl_der_gruppenaufnahmen_dieses_jahr(name_der_subgruppe, aktive_oder_philister, corporation = nil)
     users = (corporation.try(:descendant_groups) || Group).where("name like ?", name_der_subgruppe).map(&:memberships_this_year).flatten.map(&:user).uniq
     if aktive_oder_philister == :philister
       users.select! { |user| user.ancestor_groups.include? Group.alle_philister }
     elsif aktive_oder_philister == :aktive
       users.select! { |user| not user.ancestor_groups.include? Group.alle_philister }
     end
     users.count
  end

  def anzahl_der_streichungen_dieses_jahr
    anzahl_der_gruppenaufnahmen_dieses_jahr("Gestrichene", nil, nil)
  end

  def anzahl_der_austritte_dieses_jahr
    anzahl_der_gruppenaufnahmen_dieses_jahr("%Ausgetretene%", nil, nil)
  end

  def anzahl_der_philisterstreichungen_dieses_jahr(corporation = nil)
    anzahl_der_gruppenaufnahmen_dieses_jahr("Gestrichene", :philister, corporation)
  end

  def anzahl_der_philisteraustritte_dieses_jahr(corporation = nil)
    anzahl_der_gruppenaufnahmen_dieses_jahr("%Ausgetretene%", :philister, corporation)
  end

  def anzahl_der_aktivenstreichungen_dieses_jahr(corporation = nil)
    anzahl_der_gruppenaufnahmen_dieses_jahr("Gestrichene", :aktive, corporation)
  end

  def anzahl_der_aktivenaustritte_dieses_jahr(corporation = nil)
    anzahl_der_gruppenaufnahmen_dieses_jahr("%Ausgetretene%", :aktive, corporation)
  end

  def anzahlen_je_corporation
    Corporation.all.collect { |corporation|
      anzahl = yield(corporation)
      "#{corporation.token}: #{anzahl}" if anzahl > 0
    }.select(&:present?).join("<br />")
  end

  def streichungen_je_phv_dieses_jahr
    anzahlen_je_corporation do |corporation|
      anzahl_der_philisterstreichungen_dieses_jahr(corporation)
    end
  end

  def austritte_je_phv_dieses_jahr
    anzahlen_je_corporation do |corporation|
      anzahl_der_philisteraustritte_dieses_jahr(corporation)
    end
  end

  def streichungen_je_aktivitas_dieses_jahr
    anzahlen_je_corporation do |corporation|
      anzahl_der_aktivenstreichungen_dieses_jahr(corporation)
    end
  end

  def austritte_je_aktivitas_dieses_jahr
    anzahlen_je_corporation do |corporation|
      anzahl_der_aktivenaustritte_dieses_jahr(corporation)
    end
  end

end