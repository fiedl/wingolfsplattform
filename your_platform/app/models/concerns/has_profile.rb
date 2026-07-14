concern :HasProfile do

  included do
    include HasProfileFields
    include ProfileSections
  end

  def profile
    @profile ||= Profile.new(self)
  end

end