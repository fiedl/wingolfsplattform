require 'spec_helper'

# A/B verification for https://github.com/fiedl/wingolfsplattform/issues/129:
# as long as the materialized closure rows (direct: false) are still
# maintained, the recursive CTE walk over the direct links has to reach
# exactly the same nodes.
#
describe Dag::Query do

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

  it "reaches the same nodes as the materialized closure, for every node, type, and direction" do
    mismatches = []
    [Group, User, Page, Event, Project, Post, Workflow].each do |node_class|
      node_class.all.each do |node|
        node_type = node.class.base_class.name
        %w(groups users pages events projects posts workflows).each do |table|
          target_type = table.classify.constantize.base_class.name
          [:descendant, :ancestor].each do |direction|
            accessor = "#{direction}_#{table}"
            next unless node.respond_to?(accessor)
            closure_ids = if direction == :descendant
              DagLink.where(ancestor_type: node_type, ancestor_id: node.id,
                descendant_type: target_type).pluck(:descendant_id)
            else
              DagLink.where(descendant_type: node_type, descendant_id: node.id,
                ancestor_type: target_type).pluck(:ancestor_id)
            end.uniq.sort
            cte_ids = node.send(accessor).pluck(:id).uniq.sort
            unless closure_ids == cte_ids
              mismatches << "#{node.class}##{node.id} #{accessor}: closure #{closure_ids} vs cte #{cte_ids}"
            end
          end
        end
      end
    end
    mismatches.should == []
  end

  describe ".ids" do
    it "walks multiple start nodes in one query" do
      ids = Dag::Query.ids([@status1, @status2], direction: :descendant, type: 'User')
      ids.to_set.should ==
        (Dag::Query.ids(@status1, direction: :descendant, type: 'User') +
         Dag::Query.ids(@status2, direction: :descendant, type: 'User')).to_set
    end

    it "returns an empty array for no start nodes" do
      Dag::Query.ids([], direction: :descendant, type: 'User').should == []
    end
  end

  describe ".membership_episodes" do
    it "returns one episode covering the whole membership for an uninterrupted indirect membership" do
      episodes = Dag::Query.membership_episodes(@corporation, @member)
      episodes.count.should == 1
      episodes.first.first.should be_within(1.minute).of(10.years.ago)
      episodes.first.last.should == nil
    end

    it "agrees with the min/max envelope of the materialized indirect membership when there is no gap" do
      indirect = Membership.with_invalid.find_by(ancestor_id: @corporation.id, descendant_id: @member.id, direct: false)
      indirect.recalculate_validity_range_from_direct_memberships
      episodes = Dag::Query.membership_episodes(@corporation, @member)
      episodes.first.first.to_i.should == indirect.reload.valid_from.to_i
      episodes.last.last.should == indirect.valid_to
    end

    it "returns a closed episode for an expired membership" do
      episodes = Dag::Query.membership_episodes(@corporation, @former_member)
      episodes.count.should == 1
      episodes.first.first.should be_within(1.minute).of(10.years.ago)
      episodes.first.last.should be_within(1.minute).of(5.years.ago)
    end

    it "keeps the gap visible where the materialized indirect membership only stores the envelope" do
      # The closure row spans 10.years.ago until today, hiding that the
      # user was no member between 8 and 3 years ago -- the documented
      # limitation of IndirectMembershipValidityRange.
      episodes = Dag::Query.membership_episodes(@corporation, @rejoined_member)
      episodes.count.should == 2
      episodes.first.first.should be_within(1.minute).of(10.years.ago)
      episodes.first.last.should be_within(1.minute).of(8.years.ago)
      episodes.second.first.should be_within(1.minute).of(3.years.ago)
      episodes.second.last.should == nil
    end

    it "intersects the validity along the path" do
      # The status group joined the new corporation a year ago; its
      # long-standing member is a member of the new corporation only
      # since then.
      @new_corporation = create :corporation
      link = DagLink.create ancestor: @new_corporation, descendant: @status2, direct: true
      link.update_attributes valid_from: 1.year.ago
      episodes = Dag::Query.membership_episodes(@new_corporation, @member)
      episodes.count.should == 1
      episodes.first.first.should be_within(1.minute).of(1.year.ago)
      episodes.first.last.should == nil
    end

    it "returns no episodes for a user without any membership path" do
      Dag::Query.membership_episodes(@corporation, create(:user)).should == []
    end
  end

end
