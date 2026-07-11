require 'spec_helper'

describe DagLink do
  describe ".create" do
    before do
      @user = create :user
      @group = create :group
    end

    describe "when creating directly" do
      subject { DagLink.create ancestor_type: "Group", ancestor_id: @group.id, descendant_type: "User", descendant_id: @user.id }
      it { should be_kind_of DagLink }
      its(:type) { should == "Membership" }

      it "should create indirect memberships along" do
        @super_group = @group.parent_groups.create name: "Super group"
        subject
        @user.links_as_descendant.where(direct: true).count.should == 1
        @user.links_as_descendant.where(direct: false).count.should == 1
        @user.memberships.count.should == 1 # direct only; indirect memberships derive at read time
        @user.direct_memberships.count.should == 1
        @user.indirect_memberships.count.should == 1
      end
    end

    describe "when creating through an association" do
      subject { @group.links_as_parent.create descendant_type: "User", descendant_id: @user.id }
      it { should be_kind_of DagLink }
      its(:type) { should == "Membership" }
    end

    describe "when using the << operator" do
      subject { @group << @user }
      it { should be_kind_of Membership }
    end
  end
end

# The dag link functionality is tested extensively in the corresponding `acts-as-dag` gem.
# This test is just to make sure that the integration is propery done. Therefore, some basic scenarios are tested here.
#
# We use the Page model here to represent the dag's node objects, since it's a relatively simple model, which is already
# present in the database. If the Page model should become more extensive in the future, it's recommended to refactor
# this test to use a new model, perhaps defined in the test itself.
#
describe "Page (DagLinkNode)" do

  def setup_pages
    @page = FactoryBot.create( :page )
    @parent = FactoryBot.create( :page )
    @grandfather = FactoryBot.create( :page )
    @page.parent_pages << @parent
    @parent.parent_pages << @grandfather
  end

  before { setup_pages }

  describe "#ancestors" do
    it "should return all ancestors, not only the parents" do
      @page.ancestors.should include( @parent, @grandfather )
    end
  end

  describe "#descendants" do
    it "should return all descendants, not only the children" do
      @grandfather.descendants.should include( @parent, @page )
    end
  end

  describe "#parents" do
    it "should return only the parents rather than all ancestors" do
      @page.parents.should include( @parent )
      @page.parents.should_not include( @grandfather )
    end
  end

  describe "#children" do
    it "should return only the children rather than all descendants" do
      @grandfather.children.should include( @parent )
      @grandfather.children.should_not include( @page )
    end
  end

  describe ".descendant_ids_via_direct_links" do
    #   @group1 --- @group2 ---- @group3
    #      |     \_ @group2b _/    (diamond)
    #      |
    #   @page --- @group_behind_page
    #
    before do
      @group1 = create :group
      @group2 = @group1.child_groups.create name: 'Group 2'
      @group2b = @group1.child_groups.create name: 'Group 2b'
      @group3 = @group2.child_groups.create name: 'Group 3'
      @group2b << @group3
      @page = create :page
      @group1 << @page
      @group_behind_page = create :group
      @page << @group_behind_page
    end

    it "should walk the direct links of the given node type, transitively" do
      ids = DagLink.descendant_ids_via_direct_links('Group', [@group1.id])
      ids.should include @group2.id
      ids.should include @group2b.id
      ids.should include @group3.id
    end

    it "should return diamond nodes only once" do
      ids = DagLink.descendant_ids_via_direct_links('Group', [@group1.id])
      ids.count(@group3.id).should == 1
    end

    it "should not cross nodes of other types, unlike the indirect closure rows" do
      @group1.descendant_groups.should include @group_behind_page
      DagLink.descendant_ids_via_direct_links('Group', [@group1.id]).should_not include @group_behind_page.id
    end

    it "should not include the start ids" do
      DagLink.descendant_ids_via_direct_links('Group', [@group1.id]).should_not include @group1.id
    end

    it "should return an empty array for empty start ids" do
      DagLink.descendant_ids_via_direct_links('Group', []).should == []
    end
  end

end
