concern :GroupNameConstants do

  # Die Schreibweise der Status-Gruppen kann lokal abweichen, wenn die Gruppen umbenannt wurden.
  # Bis wir eine Identifikation der Gruppen anhand von Flags haben, müssen die Gruppen anhand
  # verschiedener Namen erkannt werden. Daher sollen an dieser Stelle entsprechende Konstanten
  # definiert werden.
  #
  # Um herauszufinden, welche Status-Gruppen-Namen in der Datenbank existieren:
  #
  #     StatusGroup.pluck(:name).uniq
  #
  included do
    unless defined? BURSCHEN_GROUP_NAMES
      BURSCHEN_GROUP_NAMES = ["Burschen", "Bursch"]
      FUXEN_GROUP_NAMES = ["Fuxen", "Fux"]
      AKTIVE_BURSCHEN_GROUP_NAMES = ["Aktive Burschen", "Aktiver Bursch"]
      INAKTIVE_LOCI_GROUP_NAMES = ["Inaktive Burschen loci", "Inaktive loci", "Inaktiver loci"]
      INAKTIVE_NON_LOCI_GROUP_NAMES = ["Inaktive Burschen non loci", "Inaktive non loci", "Inaktive Burschen non-loci", "Inaktive non-loci", "Inaktiver non loci"]
      KONKNEIPANTEN_GROUP_NAMES = ["Konkneipanten", "Konkneipant"]
      HOSPITANTEN_GROUP_NAMES = ["Hospitanten", "Hospitant"]
      AKTIVITAS_GROUP_NAMES = ["Aktivitas"]
      PHILISTERSCHAFT_GROUP_NAMES = ["Philisterschaft", "Altherrenschaft"]
    end
  end

end