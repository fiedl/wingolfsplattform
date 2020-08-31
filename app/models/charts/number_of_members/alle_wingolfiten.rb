class Charts::NumberOfMembers::AlleWingolfiten < Charts::NumberOfMembers::Group

  def sub_charts
    [
      Charts::NumberOfMembers::Group.new(group: Group.alle_wingolfiten, name: "Aktive + Philister"),
      Charts::NumberOfMembers::Group.new(group: Group.alle_aktiven, name: "Aktive"),
      Charts::NumberOfMembers::Group.new(group: Group.alle_philister, name: "Philister")
    ]
  end

  def self._to_partial_path
    Charts::NumberOfMembers::Group._to_partial_path
  end

end