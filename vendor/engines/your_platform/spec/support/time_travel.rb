module TimeTravel
  
  def time_travel(time_difference)
    Timecop.travel (Time.now + time_difference)
  end
  
  def travel_in_time(time_difference)
    time_travel time_difference
  end
  
end