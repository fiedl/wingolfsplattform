concern :UserLeibverhaeltnisse do

  def leibbursch
    Relationship.related_users(to: self, via: "Leibbursch", opposite: "Leibfux").first
  end

  def leibbursch=(leibbursch_user)
    Relationship.where(name: "Leibbursch", user2: self).first_or_create.update user1: leibbursch_user
  end

  def leibfuxen
    Relationship.related_users(to: self, via: "Leibfux", opposite: "Leibbursch")
  end

  def leibfamilie
    familie = []
    familie << {description: "", user: self}
    if leibbursch
      relationship = Relationship.where(user1: leibbursch, name: "Leibbursch", user2: self).first
      familie << {description: "Leibbursch", user: leibbursch, relationship: relationship}
      leibbursch.leibfuxen.each do |leibfux|
        familie << {description: "Leibbruder", user: leibfux} if leibfux != self
      end
    end
    leibfuxen.each do |leibfux|
      relationship = Relationship.where(user1: self, name: "Leibbursch", user2: leibfux).first
      familie << {description: "Leibfux", user: leibfux, relationship: relationship}
    end
    if leibbursch.try(:leibbursch)
      familie << {description: "Leibopa", user: leibbursch.leibbursch}
    end
    leibfuxen.each do |leibfux|
      leibfux.leibfuxen.each do |leibenkel|
        familie << {description: "Leibenkel, Leibfux von #{leibfux.title}", user: leibenkel}
      end
    end
    if leibbursch.try(:leibbursch).try(:leibbursch)
      familie << {description: "Leiburopa", user: leibbursch.leibbursch.leibbursch}
    end
    leibfuxen.each do |leibfux|
      leibfux.leibfuxen.each do |leibenkel|
        leibenkel.leibfuxen.each do |leiburenkel|
          familie << {description: "Leiburenkel, Leibfux von #{leibenkel.title}", user: leiburenkel}
        end
      end
    end
    return familie
  end

end