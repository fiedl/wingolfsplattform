require_dependency YourPlatform::Engine.root.join('app/models/list_exports/name_list').to_s

module ListExports
  class NameList

    # Im Wingolf soll für alle Benutzer der BV angezeigt werden, dem der Benutzer
    # zugeordnet ist. Für Aktive ist dieser Eintrag leer.
    #
    alias_method :original_columns, :columns
    def columns
      original_columns + [:w_nummer, :cached_bv_token]
    end

  end
end