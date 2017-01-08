require 'spec_helper'

describe Event do
  before do
    @event = create :event
    @corporation = create :wingolf_corporation
  end
  subject { @event }

  describe "when the parent is a corporation" do
    before { @corporation << @event }
    its(:aktive) { should be true }
    its(:philister) { should be true }

    describe "#aktive=false" do
      it "should move the event to the philisterschaft" do
        @event.aktive = false; @event.save
        @event.aktive.should == false
        @event.philister.should == true
        @event.parent_groups(true).to_a.should == [@corporation.philisterschaft]
      end
    end

    describe "#philister=false" do
      it "should move the event to the aktivitas" do
        @event.philister = false; @event.save
        @event.aktive.should == true
        @event.philister.should == false
        @event.parent_groups(true).to_a.should == [@corporation.aktivitas]
      end
    end

    describe "#aktive=false, #philister=false" do
      it "should leave the event under the corporation" do
        @event.aktive = false; @event.philister = false; @event.save
        @event.ancestor_groups(true).to_a.should include @corporation
      end
    end
  end

  describe "when the parent is a sibling of aktivitas and philisterschaft" do
    before do
      @sibling = @corporation.child_groups.create name: "Arbeitskreis Satzung"
      @sibling << @event
    end
    describe "#aktive=false, #philister=false" do
      it "should leave the event in its subgroup" do
        @event.aktive = false; @event.philister = false; @event.save
        @event.parent_groups(true).to_a.should include @sibling
        @event.ancestor_groups(true).to_a.should include @corporation
      end
    end
  end

  describe "when the parent is an aktivitas" do
    before { @corporation.aktivitas << @event }
    its(:aktive) { should be true }
    its(:philister) { should be false }

    describe "#philister=true" do
      it "should move the event to the corporation" do
        @event.philister = true; @event.save
        @event.aktive.should == true
        @event.philister.should == true
        @event.parent_groups(true).to_a.should == [@corporation]
      end
    end

    describe "#philister=true, #aktive=false" do
      it "should move the event to the philisterschaft" do
        @event.philister = true; @event.aktive = false; @event.save
        @event.aktive.should == false
        @event.philister.should == true
        @event.parent_groups(true).to_a.should == [@corporation.philisterschaft]
      end
    end
  end

  describe "when the parent is a philisterschaft" do
    before { @corporation.philisterschaft << @event }
    its(:aktive) { should be false }
    its(:philister) { should be true }

    describe "#aktive=true" do
      it "should move the event to the corporation" do
        @event.aktive = true; @event.save
        @event.aktive.should == true
        @event.philister.should == true
        @event.parent_groups(true).to_a.should == [@corporation]
      end
    end

    describe "#aktive=true, #philister=false" do
      it "should move the event to the aktivitas" do
        @event.philister = false; @event.aktive = true; @event.save
        @event.aktive.should == true
        @event.philister.should == false
        @event.parent_groups(true).to_a.should == [@corporation.aktivitas]
      end
    end
  end

  describe ".create" do
    subject { Event.create(@args.merge({group_id: @corporation.id})) }
    describe "()" do
      before { @args = {} }
      its(:group) { should == @corporation }
    end
    describe "(aktive: true)" do
      before { @args = {aktive: true} }
      its(:group) { should == @corporation.aktivitas }
    end
    describe "(philister: true)" do
      before { @args = {philister: true} }
      its(:group) { should == @corporation.philisterschaft }
    end
    describe "(aktive: true, philister: true)" do
      before { @args = {aktive: true, philister: true} }
      its(:group) { should == @corporation }
    end
  end

end