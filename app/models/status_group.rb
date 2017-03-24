# This extends the your_platform StatusGroup model.
require_dependency YourPlatform::Engine.root.join('app/models/status_group').to_s

class StatusGroup

  def self.repair
    Group.where(name: ["Hospitanten", "Kraßfuxen", "Brandfuxen", "Aktive Burschen", "Inaktive Burschen loci",
      "Inaktive Burschen non loci", "Konkneipanten", "Philister", "Ehrenphilister", "Keilgäste",
      "Aktivenfreundinnen", "Philistergattinen", "Ehrenhaft Ausgetretene", "Schlicht Ausgetretene",
      "Rausgeworfene (Exclusio)", "Rausgeworfene (Dimissio)", "Gestrichene", "Verstorbene", "Alte Herren",
      "Hausbewohner", "Rezipierte Fuxen", "Silberfuxen", "Nicht-Akzeptierte Fuxen", "Akzeptierte Fuxen",
      "Krassfux", "Traditions-Chargierte"]).update_all type: "StatusGroup"
  end

end
