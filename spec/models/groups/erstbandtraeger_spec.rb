require 'spec_helper'

describe Groups::Erstbandtraeger do

  before do

    # scenario: a user is philister in two corporations.
    # He has joined corporation_a in 1960 and corporation_b in 1962.
    # The older membership defines in which corporation he is erstbandphilister.

    @some_group = create( :group )

    @corporation_a = create :wingolf_corporation
    @philisterschaft_a = @corporation_a.philisterschaft

    @philister_a = @corporation_a.status_group("Philister")
    @erstbandphilister_a = @philisterschaft_a.erstbandphilister_parent

    @corporation_b = create :wingolf_corporation
    @philisterschaft_b = @corporation_b.philisterschaft
    @philister_b = @corporation_b.status_group("Philister")
    @erstbandphilister_b = @philisterschaft_b.erstbandphilister_parent

    @corporation_c = create :wingolf_corporation
    @philisterschaft_c = @corporation_c.philisterschaft

    @user = create( :user )
    @membership_a = @philister_a.assign_user @user, at: "1960-01-01".to_datetime
    @membership_b = @philister_b.assign_user @user, at: "1962-01-01".to_datetime

    @user.reload
  end

  specify "prelims" do
    @membership_a.reload.valid_from.year.should == 1960
    @membership_b.reload.valid_from.year.should == 1962
  end


  # Redefined User Association Methods
  # ------------------------------------------------------------------------------------------

  describe "#members" do
    specify "presumption: @user is erstbandphilister of A but not of B" do
      @user.reload
      Membership.find_by_user_and_group( @user, @philisterschaft_a ).valid_from.should <
        Membership.find_by_user_and_group( @user, @philisterschaft_b ).valid_from
      @erstbandphilister_a.reload.members.should include @user
      @erstbandphilister_b.reload.members.should_not include @user
    end
    subject { @erstbandphilister_a.members }
    it "should return the child users" do
      subject.should include @user
    end
    it { subject.should be_kind_of ActiveRecord::Relation }
    it "should support pagination" do
      subject.should respond_to :page
    end
  end

end
