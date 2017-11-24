require 'spec_helper'

feature 'Impressum' do
  include SessionSteps

  describe 'for an imprint Page existing' do
    background do
      @imprint = Page.find_root.child_pages.create(title: t(:imprint), content: "This is the imprint.", published_at: 1.day.ago)
      @imprint.add_flags :imprint, :footer
    end
    scenario 'clicking on the imprint link in the footer' do
      login(:user)
      visit root_path

      within "#footer" do
        click_on I18n.t(:imprint)
      end

      page.should have_content "This is the imprint."
    end
    scenario 'viewing imprint if not logged in' do
      visit root_path
      within "#footer" do
        click_on I18n.t(:imprint)
      end
      page.should have_content "This is the imprint."
    end
  end
end
