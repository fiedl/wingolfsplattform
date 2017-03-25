require_dependency YourPlatform::Engine.root.join('app/models/event').to_s

class Event

  before_save :change_group_id_according_to_aktive_and_philister

  def aktive
    if @aktive.nil?
      @aktive = (group.kind_of?(Aktivitas) || group.kind_of?(Corporation))
    else
      @aktive
    end
  end

  def philister
    if @philister.nil?
      @philister = (group.kind_of?(Philisterschaft) || group.kind_of?(Corporation))
    else
      @philister
    end
  end

  def aktive=(new_setting)
    @aktive = new_setting.to_b
    @scope_has_changed = true
  end

  def philister=(new_setting)
    @philister = new_setting.to_b
    @scope_has_changed = true
  end

  def change_group_id_according_to_aktive_and_philister
    if group_id && (corporation = group.corporation) && @scope_has_changed
      @scope_has_changed = false
      if aktive and philister
        self.move_to corporation
      elsif aktive and not philister
        self.move_to corporation.aktivitas
      elsif not aktive and philister
        self.move_to corporation.philisterschaft
      end
    end
  end

end