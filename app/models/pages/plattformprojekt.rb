class Pages::Plattformprojekt < Page

  # To save us from managing separate routes and controllers for this
  # subclass, override the model name.
  #
  def self.model_name
    Page.model_name
  end

end