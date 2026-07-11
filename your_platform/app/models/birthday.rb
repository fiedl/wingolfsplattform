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
    ids = Graph::User.user_ids_order_by_upcoming_birthday(limit: limit)
    return User.none if ids.none?
    id_positions = ids.each_with_index.map { |id, index| "WHEN #{id.to_i} THEN #{index}" }
    User.with_birthday.where(id: ids).order(Arel.sql("CASE users.id #{id_positions.join(' ')} END"))
  end

end