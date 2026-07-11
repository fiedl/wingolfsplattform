# Corporation (Wingolfsverbindung)
#   |-- Aktivitas       <---------------
#   |-- Philisterschaft
#
class Aktivitas < Group

  scope :active, -> { where id: all.to_a.select { |aktivitas| aktivitas.members.count > 5 }.collect(&:id) }

end