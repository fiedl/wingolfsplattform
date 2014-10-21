require 'spec_helper'

# We use the Page model here as an example, since it is already represented in the database.
#
#   class Page < ActiveRecord::Base
#     is_structureable ...
#     ...
#   end

describe Structureable do

  describe ".is_structureable" do

    before { @node = create( :page ) }
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
    
    it "should have children" do
      @parent = create( :page )
      @parent.child_pages << @node
      @parent.children.count.should == 1
    end      

    it "should update the children" do
      @parent = create( :page )
      @parent.child_pages << @node
      @parent.children.count.should == 1
      @brother = create( :page )
      @parent.child_pages << @brother
      @parent.children.count.should == 2
    end      
    
    it "should have descendants" do
      @parent = create( :page )
      @parent.child_pages << @node
      @parent.descendants.count.should == 1
    end      

    it "should update the descendants after a reload" do
      @parent = create( :page )
      @parent.child_pages << @node
      @parent.descendants.count.should == 1
      @brother = create( :page )
      @parent.child_pages << @brother
      @parent.reload
      @parent.descendants.count.should == 2
    end      

    it "should cache the descendants" do
      @parent = create( :page )
      @parent.descendants.count.should == 0
      @parent.reload
      t1 = Time.now
      @parent.descendants.count.should == 0
      t2 = Time.now
      t3 = t2-t1
      # without caching it took 0.009 seconds. With caching it took 0.0007 seconds
      t3.should < 0.001
    end      
  end
  
end
