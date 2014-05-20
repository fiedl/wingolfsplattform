require 'spec_helper'

unless ActiveRecord::Migration.table_exists? :my_structureables
  ActiveRecord::Migration.create_table :my_structureables do |t|
    t.string :name
  end
end

describe Navable do
  
  before do
    class MyStructureable < ActiveRecord::Base
      attr_accessible :name
      is_structureable( ancestor_class_names: %w(MyStructureable),
                        descendant_class_names: %w(MyStructureable Group User Workflow Page) )
      is_navable
    end

    @my_structureable = MyStructureable.create( name: "My Structureable" )
  end

  describe "#navable_children" do
    before do
      @workflow = create(:workflow)
      @user = create(:user)
      @page = create(:page)
      @group = create(:group)
      @my_structureable.child_users << @user 
      @my_structureable.child_pages << @page
      @my_structureable.child_groups << @group 
      @my_structureable.child_workflows << @workflow
    end
    subject { @my_structureable.navable_children }
    
    specify "prerequisites" do
      @my_structureable.children.should include @user, @page, @group, @workflow
    end
    it "should include only navable children" do
      subject.each do |child|
        child.should respond_to :nav_node
      end
    end
    it "should include pages, users and groups" do
      subject.should include @page, @user, @group
    end

    # TODO: Maybe, later, Workflow objects become navables.
    # Then, this spec has to be changed accordingly.
    it "should not include workflows" do 
      subject.should_not include @workflow
    end
  end

  describe "(route methods)" do
    before do
      @root_page = create(:page, title: "Example.com")
      @root_page.nav_node.update_attribute(:url_component, "http://example.com/")
      @products_page = create(:page, title: "Products")
      @products_page.parent_pages << @root_page
      @phones_page = create(:page, title: "Phones")
      @phones_page.parent_pages << @products_page
    end

		describe "#cached_breadcrumbs" do
		  subject { @phones_page.cached_breadcrumbs }
		  it "should return an Array of Hashes" do
		    subject.should be_kind_of Array
		    subject.first.should be_kind_of Hash
		  end
		  specify "the Hash's attributes :title, :navable and :slim should be set" do
		    subject.first[:title].should_not == nil
		    subject.first[:navable].should_not == nil
		    subject.first[:slim].should_not == nil        
		  end
		  it { should == [ {title: "Example.com", navable: @root_page, slim: false},
		                   {title: "Products", navable: @products_page, slim: false},
		                   {title: "Phones", navable: @phones_page, slim: false} ] }
		end

		describe "#cached_ancestor_navables" do
		  subject { @phones_page.cached_ancestor_navables }
		  it "should return the navable ancestors of the NavNode's Navable" do
		    subject.should == [ @root_page, @products_page ]
		  end
		  describe "for the ancestors' ids not being in an ascending order matching the hierarchy" do
		    before do
		      
		      # The @products_page is created before the @root_page on purpose.
		      #
		      @products_page = create(:page, title: "Products") 
		      @root_page = create(:page, title: "Example.com")
		      @root_page.nav_node.update_attribute(:url_component, "http://example.com/")
		      @products_page.parent_pages << @root_page
		      @phones_page = create(:page, title: "Phones")
		      @phones_page.parent_pages << @products_page
		    end
		    it "should return the navable ancestors of the NavNode's Navable" do
		      subject.should == [ @root_page, @products_page ]
		    end
		    describe "for ambiguous routes" do
		      before do
		        @other_ancestor_page = create(:page)
		        @phones_page.parent_pages << @other_ancestor_page
		      end
		      it "should list only the first route" do
		        #
		        #   @root_page
		        #       |
		        #   @products_page   @other_ancestor_page
		        #              |       |
		        #             @phones_page
		        #
		        @phones_page.ancestors.should include @root_page, @products_page, @other_ancestor_page
		        subject.should include @root_page, @products_page
		        subject.should_not include @other_ancestor_page
		      end
		    end
		  end
		end
	end

  
end
