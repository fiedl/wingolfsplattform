require 'spec_helper'

# The recursive CTE walk over the direct links
# (https://github.com/fiedl/wingolfsplattform/issues/129): structural
# invariants and the episode semantics of derived memberships.
#
describe Dag::Traversal do

  before do
    # A corporation tree with status groups and an attached promotion
    # workflow (see the factory), plus officers, nested pages, an event
    # with an attendees group, a project, and a post -- the cross-type
    # paths (group-page-group, group-event-group) are the interesting
    # part, since both the closure and the walk have to follow them.
    @federation = create :group
    @corporation = create :corporation_with_status_groups
    @federation << @corporation
    @status1, @status2, @status3 = @corporation.status_groups

    @officers_parent = @corporation.child_groups.create name: 'Officers'
    @officers_parent.add_flag :officers_parent
    # Created as Group first: OfficerGroup callbacks need the ancestor
    # link, which only exists after the create (same approach as
    # OfficerGroup.patch_officer_groups).
    @officer_group = @officers_parent.child_groups.create name: 'Presidents'
    @officer_group.update_attribute :type, 'OfficerGroup'
    @officer_group = Group.find @officer_group.id
    @officer = create :user
    @officer_group.assign_user @officer, at: 2.years.ago

    # Diamond: member of two status groups of the same corporation.
    @member = create :user
    @status1.assign_user @member, at: 10.years.ago
    @status2.assign_user @member, at: 9.years.ago

    # Plain (non-status) subgroups: status memberships are kept gapless
    # by MembershipGapCorrection, so expiry and gaps need groups whose
    # memberships stay as invalidated.
    @committee1 = @corporation.child_groups.create name: 'Committee 1'
    @committee2 = @corporation.child_groups.create name: 'Committee 2'

    # Expired membership.
    @former_member = create :user
    @committee1.assign_user @former_member, at: 10.years.ago
    @committee1.unassign_user @former_member, at: 5.years.ago

    # Gap: left the corporation, rejoined years later.
    @rejoined_member = create :user
    @committee1.assign_user @rejoined_member, at: 10.years.ago
    @committee1.unassign_user @rejoined_member, at: 8.years.ago
    @committee2.assign_user @rejoined_member, at: 3.years.ago

    @corporation_page = create :page
    @corporation << @corporation_page
    @sub_page = create :page
    @corporation_page << @sub_page
    @blog_post = create :blog_post
    @sub_page << @blog_post

    # A group beneath a page, i.e. a group-page-group path.
    @page_group = create :group
    @corporation_page << @page_group

    @event = create :event
    @event.parent_groups << @corporation
    @attendees = @event.child_groups.create name: 'Attendees'
    @attendees.assign_user @member, at: 1.day.ago

    @project = Project.create title: 'Renovation'
    @corporation << @project

    @post = Post.create subject: 'Announcement', text: 'Hello'
    @post.parent_groups << @status1
  end

  it "does not materialize indirect links anymore" do
    DagLink.where(direct: false).count.should == 0
  end

  it "answers ancestors and descendants symmetrically, for every node and type" do
    mismatches = []
    [Group, User, Page, Event, Project, Post, Workflow].each do |node_class|
      node_class.all.each do |node|
        %w(groups users pages events projects posts workflows).each do |table|
          accessor = "descendant_#{table}"
          next unless node.respond_to?(accessor)
          node.send(accessor).each do |reached|
            reverse = "ancestor_#{node.class.base_class.name.demodulize.tableize}"
            next unless reached.respond_to?(reverse)
            unless reached.send(reverse).pluck(:id).include?(node.id)
              mismatches << "#{node.class}##{node.id} reaches #{reached.class}##{reached.id}, but not the reverse"
            end
          end
        end
      end
    end
    mismatches.should == []
  end

  describe ".descendant_ids_of" do
    it "walks multiple start nodes in one query" do
      ids = Dag::Traversal.descendant_ids_of([@status1, @status2], type: 'User')
      ids.to_set.should ==
        (Dag::Traversal.descendant_ids_of(@status1, type: 'User') +
         Dag::Traversal.descendant_ids_of(@status2, type: 'User')).to_set
    end

    it "returns an empty array for no start nodes" do
      Dag::Traversal.descendant_ids_of([], type: 'User').should == []
    end
  end

  describe ".membership_validity_ranges" do
    it "returns one range covering the whole membership for an uninterrupted indirect membership" do
      ranges = Dag::Traversal.membership_validity_ranges(@corporation, @member)
      ranges.count.should == 1
      ranges.first.begin.should be_within(1.minute).of(10.years.ago)
      ranges.first.end.should == nil
    end

    it "agrees with the envelope of the derived indirect membership when there is no gap" do
      derived = IndirectMembership.new(@corporation, @member)
      ranges = Dag::Traversal.membership_validity_ranges(@corporation, @member)
      ranges.first.begin.to_i.should == derived.valid_from.to_i
      ranges.last.end.should == derived.valid_to
    end

    it "returns a closed range for an expired membership" do
      ranges = Dag::Traversal.membership_validity_ranges(@corporation, @former_member)
      ranges.count.should == 1
      ranges.first.begin.should be_within(1.minute).of(10.years.ago)
      ranges.first.end.should be_within(1.minute).of(5.years.ago)
    end

    it "keeps the gap visible where the materialized indirect membership only stores the envelope" do
      # The closure row spans 10.years.ago until today, hiding that the
      # user was no member between 8 and 3 years ago -- the documented
      # limitation of IndirectMembershipValidityRange.
      ranges = Dag::Traversal.membership_validity_ranges(@corporation, @rejoined_member)
      ranges.count.should == 2
      ranges.first.begin.should be_within(1.minute).of(10.years.ago)
      ranges.first.end.should be_within(1.minute).of(8.years.ago)
      ranges.second.begin.should be_within(1.minute).of(3.years.ago)
      ranges.second.end.should == nil
    end

    it "intersects the validity along the path" do
      # The status group joined the new corporation a year ago; its
      # long-standing member is a member of the new corporation only
      # since then.
      @new_corporation = create :corporation
      link = DagLink.create ancestor: @new_corporation, descendant: @status2, direct: true
      link.update_attributes valid_from: 1.year.ago
      ranges = Dag::Traversal.membership_validity_ranges(@new_corporation, @member)
      ranges.count.should == 1
      ranges.first.begin.should be_within(1.minute).of(1.year.ago)
      ranges.first.end.should == nil
    end

    it "returns no ranges for a user without any membership path" do
      Dag::Traversal.membership_validity_ranges(@corporation, create(:user)).should == []
    end
  end

end
