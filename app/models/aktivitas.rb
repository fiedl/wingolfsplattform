# Corporation (Wingolfsverbindung)
#   |-- Aktivitas       <---------------
#   |-- Philisterschaft
#
class Aktivitas < Group

  scope :active, -> { where id: (joins(:members).group('groups.id').having("count(users.id) > 5")) }

end