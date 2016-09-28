require_dependency YourPlatform::Engine.root.join('app/helpers/semester_calendars_helper').to_s

module SemesterCalendarsHelper

  def semester_calendar_check_box_columns
    [:aktive, :philister, :publish_on_local_website, :publish_on_global_website]
  end

  def semester_calendar_default_contact_person(semester_calendar)
    semester_calendar.kneipwart
  end

end