require 'spec_helper'

feature "User Contact Information Page" do
  include SessionSteps

  scenario "Viewing the own contact information" do
    @user = create :user_with_account
    @user.profile_fields.create type: "ProfileFields::Phone", label: "phone", value: "+49 89 1234-56"

    login @user
    visit user_contact_information_path(@user)

    page.should have_selector '#contact'
    # The profile fields render as vue components; without a browser
    # only the component tags are visible.
    page.should have_selector 'vue_profile_field', visible: :all
  end
end
