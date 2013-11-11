require 'spec_helper'

feature 'Locales' do
  include SessionSteps

  before do
    @user = create(:user_with_account)
    login(@user)
  end

  scenario "providing the :locale parameter to display the page in different languages" do

    locale_before_scenario = I18n.locale

    # providing the url parameter should change the locale.
    #
    visit user_path(@user, :locale => :de)
    page.should have_text "Mein Profil"
    visit user_path(@user, :locale => :en)
    page.should have_text "My Profile"

    # the locale should be kept when visiting another page (using a cookie).
    #
    visit root_path
    page.should have_text "My Profile"
    page.should have_no_text "Mein Profil"

    # reset the locale to the one before the spec.
    # Since the locale is stored in a cookie, otherwise, the
    # following specs can be affected.
    #
    visit user_path(@user, :locale => locale_before_scenario)
    page.should have_text "Mein Profil"
  end

end
