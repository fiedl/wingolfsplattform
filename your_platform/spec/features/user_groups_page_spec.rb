require 'spec_helper'

feature "User's Groups Page" do
  include SessionSteps

  # The user is member of the parent group only through the subgroup.
  # There is no membership row for the parent group; the membership
  # is derived from the direct membership in the subgroup.
  #
  scenario "Viewing the groups of a user with direct and derived memberships" do
    @user = create :user_with_account
    @parent_group = create :group, name: "Parent Group"
    @subgroup = create :group, name: "Subgroup"
    @parent_group.child_groups << @subgroup
    @subgroup.assign_user @user, at: 1.year.ago

    login @user
    visit user_groups_path(@user)

    # The group names render client-side (vue). The server-rendered
    # links prove which group cards are on the page.
    page.should have_link "Profil", href: group_path(@subgroup)
    page.should have_link "Profil", href: group_path(@parent_group)
    page.should have_text "Mitglied seit"
  end
end
