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
    describe 'after adding child' do
      before do
        @child = create(:page)
        @node.child_pages << @child
      end
      it { should include @child }
    end
    describe 'after adding grandchildren' do
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
    describe 'after adding child' do
      before do
        @node.cached_descendants
        @child = create(:page)
        @node.child_pages << @child
      end
      it { should include @child }
    end
    describe 'after adding grandchildren' do
      before do
        @node.cached_descendants
        @child = create(:page)
        @grandchild = create(:page)
        @node.child_pages << @child
        @child.child_pages << @grandchild
      end
      it { should include @grandchild }
    end
    describe 'after removing grandchildren' do
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
    describe 'after multiple adding and removing' do
      before do
        @p1 = create(:page)
        @p2 = create(:page)
        @p3 = create(:page)
        @p4 = create(:page)
        @p5 = create(:page)
        @p6 = create(:page)
        @p7 = create(:page)
        @node.cached_descendants
        @node.child_pages << @p1
        @p1.child_pages << @p2
        @node.cached_descendants
        @p2.child_pages << @p4
        @node.cached_descendants
        @node.child_pages << @p3
        @node.cached_descendants
        @node.child_pages << @p5
        @p5.child_pages << @p6
        @node.cached_descendants
        @p2.destroy_dag_links
        @node.cached_descendants
        @p5.child_pages << @p7
        @node.cached_descendants
        @p6.destroy_dag_links
      end
      it { should include @p1 }
      it { should_not include @p2 }
      it { should include @p3 }
      it { should_not include @p4 }
      it { should include @p5 }
      it { should_not include @p6 }
      it { should include @p7 }
    end
  end
end

