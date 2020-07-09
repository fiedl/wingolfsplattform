class Charts::NumberOfMembers::Corporation < Charts::NumberOfMembers::Group

  def sub_charts
    [
      Charts::NumberOfMembers::Group.new(group: group, name: "Aktive + Philister"),
      Charts::NumberOfMembers::Group.new(group: group.aktivitas, name: "Aktive"),
      Charts::NumberOfMembers::Group.new(group: group.philisterschaft, name: "Philister")
    ]
  end

  def term_report
    group.term_reports.last
  end

  def self._to_partial_path
    Charts::NumberOfMembers::Group._to_partial_path
  end

end