require_dependency YourPlatform::Engine.root.join('app/models/notification').to_s

module NotificationOverride
  
  # Notifications:
  # Sollen nur an lebende Wingolfiten versandt werden, nicht aber an
  # Verstorbene oder Ausgetretene.
  # 
  # Trello: https://trello.com/c/sTcxFe7N/863
  #
  def self.deliver_for_user(user)
    if user.alive? and user.wingolfit?
      super(user)
    else
      logger.warning "Not delivering notifications to user #{user.id} #{user.title}: Der Benutzer ist entweder verstorben oder kein Wingolfit."
      return []
    end
  end
  
end

class Notification
  prepend NotificationOverride
end