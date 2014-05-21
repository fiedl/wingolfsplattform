require 'spec_helper'

RSpec.describe UserMixins::Bv do
  
  let(:user) { create :user }
  let(:bv) { create :bv_group }
  
  specify "(prelims)" do
    expect(user).to be_kind_of User
    expect(bv).to be_kind_of Group
    expect(bv).to be_kind_of Bv
  end
  
  describe "#bv" do
    subject(:user_bv) { user.bv }
    it "returns the user's bv" do
      bv.assign_user user
      user.reload

      expect(user_bv).to eq bv
    end
  end
  
  describe "#correct_bv" do
    subject(:user_correct_bv) { user.correct_bv }
    
    let(:bv0) { create(:bv_group, name: "BV 00 Unbekannt Verzogene", token: "BV 00") }
    let(:bv1) { create(:bv_group, name: "BV 01 Berlin", token: "BV 01") }
    let(:bv2) { create(:bv_group, name: "BV 45 Europe", token: "BV 45") }
    let(:address1) { "Pariser Platz 1\n 10117 Berlin" }
    let(:address2) { "44 Rue de Stalingrad, Grenoble, Frankreich" }
    let(:address_field1) { user.profile_fields.create(type: 'ProfileFieldTypes::Address', value: address1).becomes ProfileFieldTypes::Address }
    let(:address_field2) { user.profile_fields.create(type: 'ProfileFieldTypes::Address', value: address2).becomes ProfileFieldTypes::Address }
    let(:wingolf_corporation) { create :wah_group }
    
    describe "with the user being philister" do
      before do
        wingolf_corporation.philisterschaft.assign_user user
        user.reload
      end
      
      specify "prelims" do
        expect(user.philister?).to be_true
      end
    end
  end

  describe "#correct_bv" do
    before do
      @bv0 = create(:bv_group, name: "BV 00 Unbekannt Verzogene", token: "BV 00")
      @bv1 = create(:bv_group, name: "BV 01 Berlin", token: "BV 01")
      @bv2 = create(:bv_group, name: "BV 45 Europe", token: "BV 45")
      @address1 = "Pariser Platz 1\n 10117 Berlin"
      @address2 = "44 Rue de Stalingrad, Grenoble, Frankreich"
      @address_field1 = user.profile_fields.create(type: 'ProfileFieldTypes::Address', value: @address1).becomes ProfileFieldTypes::Address
      @address_field2 = user.profile_fields.create(type: 'ProfileFieldTypes::Address', value: @address2).becomes ProfileFieldTypes::Address
      BvMapping.create(bv_name: "BV 01", plz: "10117")
    end
    subject { user.correct_bv }
    
    describe "the user being philister" do
      before do
        @wah = create(:wah_group)
        @wah.philisterschaft.assign_user user
      end
      specify "prelims" do
        user.philister?.should == true
      end
      describe "for no address given" do
        before { user.address_profile_fields.destroy_all }
        it "should return BV 00" do
          subject.try(:token).should == "BV 00"
        end
      end
      describe "for addresses given, but no address being selected as postal address" do
        it "should return the BV that matches the first given address" do
          subject.should == @address_field1.bv
          @address_field1.bv.should_not == nil
        end
      end
      describe "for a postal address being selected" do
        before { @address_field2.postal_address = true }
        it "should return the BV that matches the postal address" do
          subject.should == @address_field2.bv
          @address_field2.bv.should_not == nil
        end
      end
    end
    describe "the user being aktiver" do
      before do
        @wah = create(:wah_group)
        @wah.aktivitas.assign_user user
      end
      specify "prelims" do
        user.aktiver?.should == true
      end
      it { should == nil }
    end
  end
  
  describe "#adapt_bv_to_postal_address" do
    before do
      @bv0 = create(:bv_group, name: "BV 00 Unbekannt Verzogene", token: "BV 00")
      @bv1 = create(:bv_group, name: "BV 01 Berlin", token: "BV 01")
      @bv2 = create(:bv_group, name: "BV 45 Europe", token: "BV 45")
      @address1 = "Pariser Platz 1\n 10117 Berlin"
      @address2 = "44 Rue de Stalingrad, Grenoble, Frankreich"
      @address_field1 = user.profile_fields.create(type: 'ProfileFieldTypes::Address', value: @address1).becomes ProfileFieldTypes::Address
      @address_field2 = user.profile_fields.create(type: 'ProfileFieldTypes::Address', value: @address2).becomes ProfileFieldTypes::Address
      BvMapping.create(bv_name: "BV 01", plz: "10117")
    end
    subject { user.adapt_bv_to_postal_address }
    
    specify "prelims" do
      Bv.by_address(@address1).should == @bv1
      Bv.by_address(@address2).should == @bv2
    end
    describe "for the user being philister" do
      before do
        @wah = create(:wah_group)
        @wah.philisterschaft.assign_user user
      end
      specify "prelims" do
        user.philister?.should == true
      end
      describe "for no bv membership existing" do
        describe "if no address is selected as postal address" do
          it "should assign the user to the BV the matches the first entered address" do
            subject
            user.bv.should == @bv1
            @address_field1.bv.should == @bv1
          end
          it "should return the new membership" do
            subject.should == UserGroupMembership.find_by_user_and_group(user, @bv1)
          end
        end
      end
      describe "for an address being selected as postal address that already matches the current BV" do
        before do
          @bv1.assign_user user
          @address_field1.wingolfspost = true
        end
        it "should keep the memberships as they are" do
          subject
          user.bv.should == @bv1
          
          # a double dag link would indicate that the membership had been created twice.
          user.bv_membership.count.should == 1
        end
        it "should return the kept membership" do
          old_membership = user.reload.bv_membership
          subject.should == old_membership
        end
      end
      describe "for an address being selected as postal address that matches a new BV" do
        before do
          @membership1 = @bv1.assign_user user, at: 1.year.ago
          @address_field2.wingolfspost = true
        end
        specify "prelims" do
          @address_field2.bv.should == @bv2
          user.postal_address_field.should == @address_field2
        end
        it "should assign the user to the new BV" do
          subject
          sleep 1.1  # because of the validity range time comparison
          user.reload.bv.should == @bv2
        end
        it "should end the current BV membership" do
          subject
          @membership1.reload.valid_to.should_not == nil
        end
        it "should return the new membership" do
          new_membership = subject
          membership_in_bv2 = UserGroupMembership.with_invalid.find_by_user_and_group(user, @bv2)
          membership_in_bv2.should_not == nil
          new_membership.should == membership_in_bv2
        end
      end
      describe "for an address being selected that does not match a BV" do
        before do
          @membership2 = @bv2.assign_user user, at: 1.year.ago
          BvMapping.destroy_all
          @address_field1.wingolfspost = true
        end
        specify "prelims" do
          Bv.by_address(@address1).should == nil
          @address_field1.bv.should == nil
        end
        it "should continue the old BV membership" do
          subject
          user.bv.should == @bv2
          @membership2.reload.valid_to.should == nil
        end
        it { should == @membership2 }
      end
      describe "for a user without address" do
        before do
          user.profile_fields.destroy_all
          user.reload
        end
        it "should assign the user to BV 00" do
          subject
          user.bv.token.should == "BV 00"
        end
        it "should return the new membership" do
          subject.should == UserGroupMembership.find_by_user_and_group(user, @bv0)
        end
      end
      describe "if the bv could not be determined by plz" do
        before do
          BvMapping.destroy_all
        end
        it "should assign no bv" do
          subject
          user.bv.should == nil
        end
        it { should == nil }
      end
      describe "for the user having multiple bv memberships" do
        before do
          @membership0 = @bv0.assign_user user
          @membership1 = @bv1.assign_user user
          @address_field2.wingolfspost = true  # the correct bv is @bv2.
        end
        it "should remove all old memberships" do
          subject
          sleep 1.1  # because of the time comparison of valid_from/valid_to.
          UserGroupMembership.find_by_user_and_group(user, @bv0).should == nil
          UserGroupMembership.find_by_user_and_group(user, @bv1).should == nil
        end
        specify "the user should only have ONE bv membership, now" do
          subject
          sleep 1.1  # because of the time comparison of valid_from/valid_to.
          (user.groups(true) & Bv.all).count.should == 1
        end
        it "should assign the user to the correct bv" do
          subject
          sleep 1.1  # because of the time comparison of valid_from/valid_to.
          user.reload.bv.should == @bv2
        end
        it "should return the new membership" do
          subject.should == UserGroupMembership.find_by_user_and_group(user, @bv2)
        end
      end
    end
    describe "for the user being aktiver" do
      before do
        @wah = create(:wah_group)
        @wah.aktivitas.assign_user user
      end
      specify "prelims" do
        user.aktiver?.should == true
      end
      it "should not assign a bv" do
        subject
        sleep 1.1
        user.reload.bv.should == nil
      end
      it { should == nil }      
    end
  end
  
end