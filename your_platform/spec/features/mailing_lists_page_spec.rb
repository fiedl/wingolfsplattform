require 'spec_helper'

feature "Mailing Lists Page" do
  include SessionSteps

  scenario "Viewing the mailing lists with their member counts" do
    @group = create :group, name: "Choir"
    @group.profile_fields.create type: "ProfileFields::MailingListEmail", label: "mailing_list", value: "choir@example.com"
    @member = create :user
    @group.assign_user @member, at: 1.year.ago

    login :admin
    visit mailing_lists_path

    page.should have_text "choir@example.com"
    page.should have_text "Choir"
  end
end
