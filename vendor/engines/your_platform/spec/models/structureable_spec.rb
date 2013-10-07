require 'spec_helper'

# We use the Page model here as an example, since it is already represented in the database.
#
#   class Page < ActiveRecord::Base
#     is_structureable ...
#     ...
#   end

describe Structureable do
  
  before do
    @node = create(:page)
  end

  describe ".is_structureable" do
    subject { @node }

    it "should provide the has_dag_links functionality" do
      subject.should respond_to( :parents, :children, :ancestors, :descendants )
    end

    it "should provide the has_many_flags functionality" do
      subject.should respond_to( :flags, :add_flag, :remove_flag )
    end

    it "should make sure that when objects are destroyed, also their dag links are destroyed" do
      @parent = create( :page )
      @parent.child_pages << @node
      @node.destroy
      @parent.links_as_parent.count.should == 0
    end
  end

  describe "#neo_node" do
    subject { @node.neo_node }
    it { should_not == nil }
    it "should be independent of the STI subclass" do
      @node.class.name.should == "Page"
      subject.should == @node.becomes(BlogPost).neo_node
    end
  end
  
  describe "#neo_id" do
    subject { @node.neo_id }
    it { should_not == nil }
    it "should be independent of the STI subclass" do
      @node.class.name.should == "Page"
      subject.should == @node.becomes(BlogPost).neo_id
    end
  end
  
  describe "#parents", focus: true do
    before do 
      @parent_page = @node.parent_pages.create(title: "Parent Page")
      @parent_group = @node.parent_groups.create(name: "Parent Group")
      @parents = [@parent_page, @parent_group]
    end
    subject { @node.parents }
    it "should list all parents" do
      subject.should == @parents
    end
    
  end
  
end
