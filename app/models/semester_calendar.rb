require_dependency YourPlatform::Engine.root.join('app/models/semester_calendar').to_s

class SemesterCalendar

  def senior
    officer(:senior)
  end

  def fuxmajor
    officer(:fuxmajor)
  end

  def kneipwart
    officer(:kneipwart)
  end

end