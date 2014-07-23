require 'spec_helper'

# We use the Page model here as an example, since it is already represented in the database.
#
#   class Page < ActiveRecord::Base
#     is_structureable ...
#     ...
#   end

describe Structureable do

  describe '.is_structureable' do

    before { @node = create(:page) }
    subject { @node }

    it 'should provide the has_dag_links functionality' do
      subject.should respond_to(:parents, :children, :ancestors, :descendants)
    end

    it 'should provide the has_many_flags functionality' do
      subject.should respond_to(:flags, :add_flag, :remove_flag)
    end

    it 'should make sure that when objects are destroyed, also their dag links are destroyed' do
      @parent = create(:page)
      @parent.child_pages << @node
      @node.destroy
      @parent.links_as_parent.count.should == 0
    end
  end

  describe '#descendants' do
    before do
      @node = create(:page)
    end
    subject { @node.descendants }
    it { should == [] }
    describe "after adding child" do
      before do
        @child = create(:page)
        @node.child_pages << @child
      end
      it { should include @child }
    end
    describe "after adding grandchildren" do
      before do
        @child = create(:page)
        @grandchild = create(:page)
        @node.child_pages << @child
        @child.child_pages << @grandchild
      end
      it { should include @grandchild }
    end
  end
  
    describe '#cached_descendants' do
    before do
      @node = create(:page)
    end
    subject { @node.cached_descendants }
    it { should == [] }
    describe "after adding child" do
      before do
        @node.cached_descendants
        @child = create(:page)
        @node.child_pages << @child
      end
      it { should include @child }
    end
    describe "after adding grandchildren" do
      before do
        @node.cached_descendants
        @child = create(:page)
        @grandchild = create(:page)
        @node.child_pages << @child
        @child.child_pages << @grandchild
      end
      it { should include @grandchild }
    end
    describe "after removing grandchildren" do
      before do
        @child = create(:page)
        @grandchild = create(:page)
        @node.child_pages << @child
        @child.child_pages << @grandchild
        @node.cached_descendants
        @grandchild.destroy_dag_links
      end
      it { should_not include @grandchild }
    end
  end
end

