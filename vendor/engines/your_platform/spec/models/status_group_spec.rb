require 'spec_helper'

describe StatusGroup do
  
  # @corporation_a
  #      |--- @intermediate_group
  #      |            |---------------- @status_a_1 ---- @user
  #      |            |---------------- @status_a_2
  #      |
  #      |--- @officers_parent
  #                   |---------------- @admins_parent - @user
  #
  # @corporation_b
  #      |----------------------------- @status_b_1
  #      |----------------------------- @status_b_2 ---- @user
  #
  before do
    @corporation_a = create(:corporation)
    @intermediate_group = @corporation_a.child_groups.create(name: "Intermediate Group")
    @status_a_1 = @intermediate_group.child_groups.create(name: "Status a 1")
    @status_a_2 = @intermediate_group.child_groups.create(name: "Status a 2")
    @officers_parent = @corporation_a.create_officers_parent_group
    @admins_parent = @corporation_a.find_or_create_admins_parent_group
    
    @corporation_b = create(:corporation)
    @status_b_1 = @corporation_b.child_groups.create(name: "Status b 1")
    @status_b_2 = @corporation_b.child_groups.create(name: "Status b 2")
    
    @user = create(:user)
    @status_a_1.assign_user @user, at: 1.day.ago
    @admins_parent.assign_user @user, at: 1.day.ago
    @status_b_2.assign_user @user, at: 1.day.ago
  end
  
  describe ".find_all_by_corporation" do
    subject { StatusGroup.find_all_by_corporation(@corporation_a) }
    it { should include @status_a_1, @status_a_2 }
    it { should_not include @intermediate_group }
    it { should_not include @admins_parent }
    it "should be equivalent to Corporation#status_groups" do
      subject.should == @corporation_a.status_groups
    end
  end
  
  describe ".find_all_by_user" do
    subject { StatusGroup.find_all_by_user(@user) }
    it { should include @status_a_1, @status_b_2 }
    it { should_not include @status_a_2, @status_b_1 }
    it { should_not include @intermediate_group }
    it { should_not include @admins_parent }

    describe "after a promotion" do
      before { UserGroupMembership.find_by_user_and_group(@user, @status_a_1).move_to @status_a_2, at: 10.minutes.ago }
      it { should include @status_a_2 }
      it { should_not include @status_a_1 }
      
      it "should be equivalent to User#status_groups" do
        subject.should == @user.status_groups
      end

      describe "(with_invalid: true)" do
        subject { StatusGroup.find_all_by_user(@user, with_invalid: true) }
        it { should include @status_a_1, @status_a_2 }
        it "should be equivalent to User#status_groups(with_invalid: true)" do
          subject.should == @user.status_groups(with_invalid: true)
        end
      end

    end
  end
  
  describe ".find_by_user_and_corporation" do
    subject { StatusGroup.find_by_user_and_corporation(@user, @corporation_a) }
    it { should be_kind_of Group }
    it { should == @status_a_1 }
    it "should be equivalent to User#current_status_group_in" do
      subject.should == @user.current_status_group_in(@corporation_a)
    end
  end
  
end
