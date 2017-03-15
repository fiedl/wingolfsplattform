require_dependency YourPlatform::Engine.root.join('app/models/event').to_s

class Event

  attr_accessible :aktive, :philister if defined? attr_accessible

  before_save :save_scope_association_if_needed
  before_save :assign_to_group_given_by_group_id

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

  def save_scope_association_if_needed
    if group
      if corporation = group.corporation
        if @scope_has_changed
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
  end

  def assign_to_group_given_by_group_id
    binding.pry
    if self.group_id && (corporation = Group.find(self.group_id)) && corporation.kind_of?(Corporation)
      if aktive and not philister
        self.group_id = corporation.aktivitas.id
      elsif philister and not aktive
        self.group_id = corporation.philisterschaft.id
      end
      @scope_has_changed = false
    end
    #self.group = Group.find(self.group_id) if self.group_id
  end

end