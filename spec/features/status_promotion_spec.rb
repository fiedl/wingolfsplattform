require 'spec_helper'

feature 'Status Promotion' do
  include SessionSteps

  before do
    @corporation = create :wingolf_corporation
    @user_to_promote = create :user
    @corporation.status_groups.first.assign_user @user_to_promote, at: 1.year.ago
    @local_admin = create :user_with_account
    @corporation.aktivitas.admins << @local_admin

    @workflow = @corporation.status_groups.first.child_workflows.first
    @workflow.delete_cache
  end

  specify 'prelims' do
    @workflow.should be_kind_of Workflow
    Ability.new(@local_admin).can?(:execute, @workflow).should be true
    Ability.new(@local_admin).can?(:change_status, @user_to_promote).should be true

    @workflow.steps.first.brick_name.should be_present
    expect { @workflow.execute(user_id: @user_to_promote.id) }.not_to raise_error
  end

  scenario 'promote user from first to second status', js: true do
    login @local_admin
    visit user_path(@user_to_promote)

    within('.box.section.general') do
      find('.workflow_triggers').click
      find('.workflow_trigger').click
    end

    page.should have_no_selector '.workflow_trigger', visible: true
    page.should have_text @user_to_promote.name
    page.should have_selector '.workflow_triggers'

    # Because all caches are renewed synchronously in the specs, this takes forever.
    # In production, the status workflows controller makes sure that the cache
    # is properly renewed.
    #
    wait_until(timeout: 120.seconds) { @user_to_promote.reload.ancestor_groups.reload.include? @corporation.status_groups.second }

    click_tab :corporate_info_tab
    within("#corporate_vita") { page.should have_text @corporation.status_groups.second.name.singularize }

    @user_to_promote.should be_member_of @corporation.status_groups.second
    @user_to_promote.should_not be_member_of @corporation.status_groups.first
  end

end