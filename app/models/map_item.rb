require_dependency YourPlatform::Engine.root.join('app/models/map_item').to_s

module MapItemOverrides

  def image_attachments
    # Wir wollen als Bild das Wingolfshaus zeigen.
    object.image_attachments.wingolfshaus
  end

  def longitude
    case title
    when "Wingolf zu Wien"
      # Um die Karte kompakt darzustellen, wurde Österreich verkleinert und etwas abgerückt.
      # Die Koordinate von Wien muss daher korrigiert werden.
      14.8
    when "Arminia Dorpatensis"
      # Um die Karte kompakt darzustellen, wurde Estland verkleinert und verschoben.
      # Die Koordinate von Dorpat muss daher korrigiert werden.
      15.8
    when "Hohenheimer Wingolf-Verbindung Fraternitas Academica"
      # Hohenheim müssen wir etwas nach rechts versetzen, damit
      # es Stuttgart nicht verdeckt.
      super + 0.3
    when "Marburger Wingolf"
      # Den Marburger Wingolf versetzen wir etwas, da er sonst
      # auf dem ClzM liegt.
      super + 0.3
    when "Heidelberger Wingolf"
      # Den Heidelberger Wingolf auch nach rechts, damit er nicht
      # auf Mannheim liegt.
      super + 0.3
    else
      super
    end
  end

  def latitude
    case title
    when "Wingolf zu Wien"
      # Um die Karte kompakt darzustellen, wurde Österreich verkleinert und etwas abgerückt.
      # Die Koordinate von Wien muss daher korrigiert werden.
      47.6
    when "Arminia Dorpatensis"
      # Um die Karte kompakt darzustellen, wurde Estland verkleinert und verschoben.
      # Die Koordinate von Dorpat muss daher korrigiert werden.
      55.2
    else
      super
    end
  end

end

class MapItem
  prepend MapItemOverrides
end