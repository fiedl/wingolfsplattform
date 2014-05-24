module TimeTravel
  
  def time_travel(time_difference)
    Timecop.travel (Time.now + time_difference)
  end
  
end