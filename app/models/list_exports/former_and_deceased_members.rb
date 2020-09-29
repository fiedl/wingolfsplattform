require_dependency YourPlatform::Engine.root.join('app/models/list_exports/former_and_deceased_members').to_s

module ListExports
  class FormerAndDeceasedMembers

    # Im Wingolf soll für alle Benutzer der BV angezeigt werden, dem der Benutzer
    # zugeordnet ist. Für Aktive ist dieser Eintrag leer.
    #
    alias_method :original_columns, :columns
    def columns
      original_columns + [:last_bv_name, :fruehere_aktivitaetszahl, :w_nummer]
    end

  end
end