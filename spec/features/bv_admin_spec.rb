require 'spec_helper'

feature "BV-Admins" do
  include SessionSteps
  
  before do
    @bv = create(:bv)
    @user = @bv_admin = create(:user_with_account)
    @bv.admins << @bv_admin
    time_travel 2.seconds
    
    login @bv_admin
  end
  
  if ENV['CI'] != 'travis'  # TODO: Why does this fail on travis, but work locally?
    scenario "Managing Officers through officers#index", :js do
      @bv_leiter = @bv.create_officer_group name: "BV-Leiter"
      @bv_leiter.add_flag :bv_leiter
      
      visit group_officers_path(@bv)
      within '.box.first' do
        # Admins and BV-Leiter should already be listed.
        page.should have_text I18n.t(:admins)
        page.should have_text @bv_admin.name
        page.should have_text "BV-Leiter"
        
        # The admin can't rename the officer group which has a flag.
        click_on I18n.t(:edit)
        page.should have_no_selector "input[value='#{@bv_leiter.name}']"
        
        # But he can assign users.
        fill_in :direct_members_titles_string, with: @user.title
        find('.save_button').click
        page.should have_text I18n.t(:admins)
        page.should have_text "BV-Leiter"
        page.should have_text @user.name, count: 2
        
        # He can create a new office.
        within '#new_officer_group' do
          fill_in 'officer_group_name', with: 'Bierkassenwart'
          find('input[type="submit"]').click
        end
        page.should have_text "Bierkassenwart"
        
        # He could desstroy the new office.
        click_on I18n.t(:edit)
        page.should have_selector '.remove_button', count: 1
    
        # He can rename the new office, which has no flag.
        # TODO: page.should have_selector "input[value='Bierkassenwart']"
        within all("td.name").last do
          fill_in :name, with: 'Getränkekassenwart'
        end
        find('.save_button').click
        page.should have_text 'Getränkekassenwart'
      end
      
      # The changes should be persistent:
      visit group_officers_path(@bv)
      within '.box.first' do
        page.should have_text I18n.t(:admins)
        page.should have_text "BV-Leiter"
        page.should have_text @user.name, count: 2
        page.should have_text 'Getränkekassenwart'
      end
      
      # He can destroy only the new office, which has no members and no flags.
      click_on I18n.t(:edit)
      within '.box.first' do
        find('.remove_button').click
        page.should have_no_text "Getränkekassenwart"
      end
      
      # The change should be persistent:
      visit group_officers_path(@bv)
      within '.box.first' do
        page.should have_no_text "Getränkekassenwart"
      end
    end
  end
  
  scenario "Using the Role-Preview Menu" do
    visit group_path(@bv)

    Role.of(@bv_admin).for(@bv).to_s.should == 'admin'
    Role.of(@bv_admin).for(@bv).admin?.should == true
    Role.of(@bv_admin).for(@bv).officer?.should == true
    
    within "#logged-in-bar" do
      within ".role-preview-switcher" do
        page.should have_text I18n.t(:admin)
        within ".dropdown-menu" do
          page.should have_selector '.issues_task'
          page.should have_text "0 #{I18n.t(:administrative_issues)}"
          page.should have_text I18n.t(:admin)
          page.should have_text I18n.t(:officer)
          page.should have_text I18n.t(:user)
        end
      end
    end
    
    within ".role-preview-switcher" do
      click_on "0 #{I18n.t(:administrative_issues)}"
    end
    within ".box.first" do
      page.should have_text "#{I18n.t(:administrative_issues)} (0)"
    end
    
    visit group_path(@bv)
    within ".box.first" do
      page.should have_text I18n.t(:edit), visible: true
    end
    within ".role-preview-switcher" do
      click_on I18n.t(:officer)
    end
    within ".box.first" do
      page.should have_no_text I18n.t(:edit), visible: true
    end
    within ".role-preview-switcher" do
      click_on I18n.t(:admin)
    end
    within ".box.first" do
      page.should have_text I18n.t(:edit), visible: true
    end
  end
  
end