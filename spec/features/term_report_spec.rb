require 'spec_helper'

feature 'TermReports' do
  include SessionSteps

  before do
    @corporation = create :wingolf_corporation

    @member = create :user
    @corporation.status_group("Aktive Burschen").assign_user @member, at: 1.day.ago

    @local_admin = create :user_with_account
    @corporation.aktivitas.assign_admin @local_admin

    @senior = create :user_with_account
    @corporation.descendant_groups.where(name: "Senior").first.assign_user @senior

    # TODO Update corresponding to feature switches:
    @local_admin.developer = true
  end

  scenario "Submitting a term report" do
    login @local_admin
    visit group_members_path @corporation
    click_on :term_report


  end
end
