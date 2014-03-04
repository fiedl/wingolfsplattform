require 'spec_helper'

describe "RemoveFromGroupBrick: " do

  describe "RemoveFromGroupBrick" do
    before do
      @user = create( :user )
      @indirect_group = create(:group)
      @indirect_group.name = "indirect"
      @indirect_group.save
      @direct_group_a = @indirect_group.child_groups.create
      @direct_group_a.name = "A"
      @direct_group_a << @user
      @direct_group_a.save
      @direct_group_b = @indirect_group.child_groups.create
      @direct_group_b.name = "B"
      @direct_group_b.save
      @workflow = Workflow.create( name: "promotion", description: "Promote a user from one group to another" )
      @workflow.steps.create( brick_name: "RemoveFromGroupBrick", parameters: { :group_id => @indirect_group.id }, :sequence_index => 1 )
      @workflow.steps.create( brick_name: "AddToGroupBrick", parameters: { :group_id => @direct_group_b.id }, :sequence_index => 2 )
    end

    describe "#execute" do
      subject { @user.direct_memberships.collect{ |x| x.group } }
      describe "initially" do
        it do
          should include @direct_group_a
          should have(1).item
        end
      end
      describe "after workflow step 1 execution" do
        before do
          @workflow.steps.first.execute( :user_id => @user.id )
        end
        it do
          should_not include @direct_group_a
          should have(0).items
        end
      end
      describe "after workflow execution" do
        before { @workflow.execute( :user_id => @user.id ) }
        it do
          should include @direct_group_b
          should have(1).item
        end
      end
    end
  end
end
