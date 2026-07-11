class Birthday
  attr_accessor :user
  attr_accessor :date
  attr_accessor :age

  def initialize(args)
    self.user = args[:user]
    self.date = args[:date]
    self.age = args[:age]
  end

  def self.upcoming
    users_ordered_by_upcoming_birthday.collect do |user|
      self.new(user: user, date: user.next_birthday, age: user.next_age)
    end
  end

  private

  def self.users_ordered_by_upcoming_birthday(limit: 3)
    today = Time.zone.now.strftime("%m-%d")
    upcoming_user_ids = User.with_birthday
      .joins(:date_of_birth_profile_field).pluck("users.id", "profile_fields.value")
      .collect { |id, value| [id, (value.to_date.strftime("%m-%d") rescue nil)] }
      .select { |_, birthday| birthday }
      .sort_by { |_, birthday| [(birthday < today) ? 1 : 0, birthday] }
      .first(limit).collect(&:first)
    User.where(id: upcoming_user_ids).sort_by { |user| upcoming_user_ids.index(user.id) }
  end

end