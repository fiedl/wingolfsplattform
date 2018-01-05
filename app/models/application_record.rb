require_dependency YourPlatform::Engine.root.join('app/models/application_record').to_s

class ApplicationRecord

  # Deaktiviere den experimentellen Renew-Cache-Mechanismus für den Moment.
  # https://trello.com/c/QyxiGXkw/1228
  def renew_cache(options = {})
    delete_cache
  end

end
