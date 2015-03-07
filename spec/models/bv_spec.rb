require 'spec_helper'

describe Bv do
  
  describe "for an empty database" do
    describe ".all" do
      subject { Bv.all }
      it { should == [] }
    end
    describe ".pluck(:id)" do
      subject { Bv.pluck(:id) }
      it { should == [] }
    end
  end
  
  describe "with a bv and a group in the database" do
    before do
      @bv = create :bv
      @other_group = create :group
    end
    
    describe ".create" do
      subject { Bv.create name: 'BV 01' }
    
      it { should be_kind_of Bv }
      it { should be_kind_of Group }
      its(:type) { should == 'Bv' }

      it "should be child of the bvs_parent group" do
        subject.reload.parent_group_ids.should include Bv.bvs_parent.id
      end
    end
    
    specify "the dag links should have Group, not Bv as type" do
      link = @bv.reload.links_as_child.first
      link.descendant_type.should_not == 'Bv'
      link.descendant_type.should == 'Group'
    end
    
    describe ".all" do
      subject { Bv.all }
      it { should include @bv }
      it { should_not include @other_group }
    end
    
    describe ".pluck(:id)" do
      subject { Bv.pluck(:id) }
      it { should include @bv.id }
      it { should_not include @other_group.id }
    end
    
    describe ".bvs_parent" do
      subject { Bv.bvs_parent }
    
      it { should be_kind_of Group }
      it { should_not be_kind_of Bv }
      its(:children) { should include @bv }
      its(:children) { should_not include @other_group }
    end
  end

end