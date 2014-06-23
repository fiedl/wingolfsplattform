# -*- coding: utf-8 -*-
require 'spec_helper'

describe HorizontalNav do

  before do
    @user = create( :user )
    @corporationE = create( :corporation_with_status_groups, :token => "E" )
    @subgroupE1 = create( :group );
    @subgroupE1.parent_groups << @corporationE
    @subgroupE2 = create( :group );
    @subgroupE2.parent_groups << @corporationE
    @former_group = @corporationE.child_groups.create
    @former_group.add_flag :former_members_parent
    @corporationS = create( :corporation_with_status_groups, :token => "S" )
    @subgroupS = create( :group );
    @subgroupS.parent_groups << @corporationS
    @user.save
    @first_membership_E = StatusGroupMembership.create( user: @user, group: @corporationE.status_groups.first )
    @user.parent_groups << @subgroupE1
    @user.reload
    @horizontal_nav = HorizontalNav.for_user( @user, :current_navable=>@first_membership_E.group )
  end

  describe "#cached_most_special_category" do
    subject { @horizontal_nav.cached_most_special_category }
    it "should return the most special category" do
      should == @horizontal_nav.most_special_category
    end
    context "when user entered second status group" do
      before do
        @horizontal_nav.cached_most_special_category
        second_membership_E = StatusGroupMembership.create( user: @user, group: @corporationE.status_groups.second )
        second_membership_E.update_attributes(valid_from: "2010-05-01".to_datetime)
        @user.reload
      end
      it { should == @horizontal_nav.most_special_category }
    end
    context "when user entered second corporation and leaving first" do
      before do
        @horizontal_nav.cached_most_special_category
        second_membership_E = StatusGroupMembership.create( user: @user, group: @former_group )
        second_membership_E.update_attributes(valid_from: "2014-05-01".to_datetime)
        @first_membership_E.update_attributes(valid_to: "2014-05-01".to_datetime)
        first_membership_S = StatusGroupMembership.create( user: @user, group: @corporationS.status_groups.first )
        first_membership_S.update_attributes(valid_from: "2010-05-01".to_datetime)
        @user.reload
      end
      it { should == @horizontal_nav.most_special_category }
    end
  end
  
end

