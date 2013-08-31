require 'spec_helper'

feature "Erstbandphilister" do
  include SessionSteps

  before do
    @corporation = create(:corporation)
    @philisterschaft_group = @corporation.child_groups.create(name: "Philisterschaft")
    @regular_philister_group = @philisterschaft_group.child_groups.create(name: "Philister")
    @philisterschaft_group.create_erstbandphilister_parent_group
    @philister_user = create(:user_with_account)
    @regular_philister_group.assign_user @philister_user

    login(@philister_user)
  end

  specify "visit corporation site and navigate to the erstbandphilister site" do
    visit group_path(@corporation)
    within(".vertical_menu") { click_on "Philisterschaft" }
    within(".vertical_menu") { click_on "Erstbandphilister" }
    within("#content_area") do
      page.should have_content "Erstbandphilister"
      page.should have_content @philister_user.title
      @philister_user.title.length.should > 5
    end
  end

end
