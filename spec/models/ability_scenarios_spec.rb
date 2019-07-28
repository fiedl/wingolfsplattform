# In dieser Spezifikation werden einige Rechte-Szenarios durchgespielt,
# um sicherzustellen, dass bestimmte Amtsträger die benötigten Rechte
# besitzen.
#
require 'spec_helper'
require 'cancan/matchers'

RSpec.configure do |c|
  c.alias_example_to :he
end

describe Ability do

  let(:user) { create(:user_with_account) }
  let(:ability) { Ability.new(user) }
  subject { ability }
  let(:the_user) { subject }

  describe "Seminarbeauftragter des Wingolfs" do
    before do
      @wingolfsseminar_page = Page.intranet_root.child_pages.create title: "Wingolfsseminar"  # no author!
      @wingolfsseminar_page.update_attribute :created_at, 10.days.ago
      @seminarbeauftragter_group = @wingolfsseminar_page.officers_parent.child_groups.create name: "Seminarbeauftragter des Wingolfs"
      @seminarbeauftragter_group << user
    end
    he { should be_able_to :update, @wingolfsseminar_page }
    he { should_not be_able_to :destroy, @wingolfsseminar_page }

    he "should be able to create and update a sub-page" do
      the_user.should be_able_to :create_page_for, @wingolfsseminar_page

      @sub_page = @wingolfsseminar_page.child_pages.create title: "Sub Page"
      the_user.should be_able_to :update, @sub_page
    end

    he "should be able to upload, edit and destroy an attachment" do
      the_user.should be_able_to :create_attachment_for, @wingolfsseminar_page

      @attachment = @wingolfsseminar_page.attachments.create title: "Attachment"
      @attachment.update_attribute :author_user_id, user.id
      the_user.should be_able_to :update, @attachment
      the_user.should be_able_to :destroy, @attachment
    end

    describe "Der Seminarbeauftragte ist ein Bundesamtsträger" do
      before do
        @seminarbeauftragter_group.add_flag :global_officer
      end

      he { should be_able_to :create_event_for, Group.everyone }
      he { should be_able_to :create_event_for, Group.alle_wingolfiten }

      he { should be_able_to :create_post_for, Group.alle_aktiven }

      describe "Wenn er ein Seminar als Veranstaltung eingetragen hat" do
        before do
          @seminar_event = Group.alle_wingolfiten.events.create name: "75. Wingolfsseminar"
          @seminar_event.contact_people_group.child_users << user
        end

        he { should be_able_to :update, @seminar_event }
        he { should be_able_to :create_attachment_for, @seminar_event }
        he { should be_able_to :create_page_for, @seminar_event }

        describe "Wenn er eine Unterseite mit Tagungsunterlagen erstellt hat" do
          before do
            @tagungsunterlagen_page = @seminar_event.child_pages.create title: "Tagungsunterlagen"
            @tagungsunterlagen_page.update_attribute :author_user_id, user.id
          end

          he { should be_able_to :update, @tagungsunterlagen_page }
          he { should be_able_to :create_attachment_for, @tagungsunterlagen_page }
        end
      end
    end
  end

  describe "Mitglied des Philisterrates" do
    before do
      @phr_group = create :group, name: "Philisterrat"
      @phr_group.assign_user user, at: 1.year.ago
      @protokolle_page = @phr_group.child_pages.create title: "Protokolle"
      @protokoll_attachment = @protokolle_page.attachments.create title: "Protokoll"
      @protokoll_attachment.update_attribute :author_user_id, create(:user).id
    end

    he { should be_able_to :read, @protokolle_page }
    he { should be_able_to :read, @protokoll_attachment }
    he { should be_able_to :download, @protokoll_attachment }

    describe "Als Protokollant" do
      before do
        @protokollanten_group = @phr_group.officers_parent.child_groups.create name: "Protokollanten"
        @protokollanten_group.assign_user user, at: 1.year.ago
      end

      he { should be_able_to :create_attachment_for, @protokolle_page }

      describe "Als Verfasser eines Protokolls" do
        before do
          @protokoll_attachment = @protokolle_page.attachments.create title: "Protokoll"
          @protokoll_attachment.update_attribute :author_user_id, user.id
        end

        he { should be_able_to :update, @protokoll_attachment }
        he { should be_able_to :destroy, @protokoll_attachment }

        describe "Als ehemaliges Mitglied des Philisterrates" do
          before do
            @phr_group.unassign_user user, at: 30.days.ago
            @protokollanten_group.unassign_user user, at: 30.days.ago
          end

          he { should be_able_to :read, @phr_group }
          he { should_not be_able_to :read, @protokolle_page }
          he { should_not be_able_to :update, @protokolle_page }
          he { should_not be_able_to :read, @protokoll_attachment }
          he { should_not be_able_to :update, @protokoll_attachment }
          he { should_not be_able_to :destroy, @protokoll_attachment }

        end
      end
    end
  end

  describe "Schriftleiter der Wingolfsblätter" do
    before do
      @wbl_page = Page.intranet_root.child_pages.create title: "Wingolfsblätter"
      @schriftleiter_group = @wbl_page.officers_parent.child_groups.create name: "Schriftleiter der Wingolfsblätter"
      @schriftleiter_group << user

      @abo_group = @wbl_page.child_groups.create name: "Abonnenten der Wingolfsblätter"
      @abo_user = create(:user)
      @abo_group << @abo_user
    end

    he { should be_able_to :update, @wbl_page }
    he { should be_able_to :export_member_list, @abo_group }
    he { should_not be_able_to :update, @abo_group }
    he { should_not be_able_to :update, @abo_user }

    he { should be_able_to :create_page_for, @wbl_page }

    describe "Wenn er die Unterseite Wingolfsblätter 2014 nicht selbst erstellt hat" do
      before do
        @wbl_2014_page = @wbl_page.child_pages.create title: "Wingolfsblätter 2014"
        @wbl_2014_page.update_attribute :author_user_id, create(:user).id
      end

      he { should be_able_to :create_attachment_for, @wbl_2014_page }

      describe "Wenn er darin eine Wingolfsblätter-Ausgabe hochgeladen hat" do
        before do
          @wbl_attachment = @wbl_2014_page.attachments.create title: "Wingolfsblätter 4/2014"
          @wbl_attachment.update_attribute :author_user_id, user.id
        end

        he { should be_able_to :update, @wbl_attachment }
        he { should be_able_to :destroy, @wbl_attachment }
      end
    end

    describe "Wenn er die Seite 'Wingolfsblätter 2015' erstellt hat" do
      before do
        @wbl_2015_page = @wbl_page.child_pages.create title: "Wingolfsblätter 2015"
        @wbl_2015_page.update_attribute :author_user_id, user.id
      end

      he { should be_able_to :create_attachment_for, @wbl_2015_page }

      describe "Wenn er darin eine Wingolfsblätter-Ausgabe hochgeladen hat" do
        before do
          @wbl_attachment = @wbl_2015_page.attachments.create title: "Wingolfsblätter 1/2015"
          @wbl_attachment.update_attribute :author_user_id, user.id
        end

        he { should be_able_to :update, @wbl_attachment }
        he { should be_able_to :destroy, @wbl_attachment }
      end

      describe "Wenn ein anderer darin eine Wbl-Ausgabe hochgeladen hat" do
        before do
          @wbl_attachment_eines_anderen = @wbl_2015_page.attachments.create title: "Wingolfsblätter 2/2015"
          @wbl_attachment_eines_anderen.update_attribute :author_user_id, create(:user).id
        end

        he { should be_able_to :update, @wbl_attachment_eines_anderen }
        he { should be_able_to :destroy, @wbl_attachment_eines_anderen }
      end
    end
  end

  describe "Datenbankbeauftragter des Wingolfs" do
    before do
      user.global_admin = true
    end

    he { should be_able_to :create_page_for, Page.intranet_root }

    describe "Als Verfasser eines Blog-Posts" do
      before do
        @blog_post = Page.intranet_root.child_pages.create title: "Abwesenheit der Geschäftsstelle"
        @blog_post.update_attribute :author_user_id, user.id
      end

      he { should be_able_to :update, @blog_post }

      describe "Als ehemaliger Datenbankbeauftragter des Wingolfs" do
        before do
          time_travel 1.month
          user.global_admin = false
        end

        he { should_not be_able_to :update, @blog_post }
      end
    end
  end

  describe "Potentieller Veranstaltungsteilnehmer" do
    before do
      @event = create :event

      @foto_von_jemand_anderem = @event.attachments.create title: "Ein Foto von jemand anderem"
      @foto_von_jemand_anderem.update_attribute :author_user_id, create(:user).id
    end

    he { should be_able_to :join, @event }
    he { should be_able_to :create_attachment_for, @event }

    describe "Als Teilnehmer der Veranstaltung" do
      before do
        user.join @event
      end

      he { should be_able_to :leave, @event }
      he { should be_able_to :create_attachment_for, @event }

      describe "Als Bereitsteller eines Veranstaltungs-Fotos" do
        before do
          @foto = @event.attachments.create title: "Ein tolles Veranstaltungsbild"
          @foto.update_attribute :author_user_id, user.id
        end

        he { should be_able_to :update, @foto }
        he { should be_able_to :destroy, @foto }
        he { should_not be_able_to :update, @foto_von_jemand_anderem }
        he { should_not be_able_to :destroy, @foto_von_jemand_anderem }
      end
    end
  end

  describe "Lokaler Admin (Aktivitas + Philisterschaft)" do
    before do
      @corporation = create :wingolf_corporation
      @corporation.assign_admin user
      @other_member = create :user; @corporation.aktivitas << @other_member
    end

    he { should be_able_to :create_account_for, @other_member }

    he "should not be able to change the admin" do
      the_user.should_not be_able_to :update_memberships, @corporation.admins_parent
    end
  end

  describe "Lokaler Admin (Philisterschaft)" do
    before do
      @corporation = create :wingolf_corporation
      @corporation.philisterschaft.assign_admin user
    end

    he "should not be able to change the admin" do
      the_user.should_not be_able_to :update_memberships, @corporation.philisterschaft.admins_parent
    end
  end

  describe "Lokaler Admin (Aktivitas)" do
    before do
      @corporation = create :wingolf_corporation
      @corporation.aktivitas.assign_admin user
    end

    he "should be able to change the admin" do
      the_user.should be_able_to :update_memberships, @corporation.aktivitas.admins_parent
    end
    he "should not be able to change the corporations admin" do
      the_user.should_not be_able_to :update_memberships, @corporation.admins_parent
    end
    he "should not be able to change the philister admin" do
      the_user.should_not be_able_to :update_memberships, @corporation.philisterschaft.admins_parent
    end
    he "should not be able to change the admin of another aktivitas or corporation" do
      @other_corporation = create :wingolf_corporation
      the_user.should_not be_able_to :update_memberships, @other_corporation.admins_parent
      the_user.should_not be_able_to :update_memberships, @other_corporation.aktivitas.admins_parent
      the_user.should_not be_able_to :update_memberships, @other_corporation.philisterschaft.admins_parent
    end

    describe "if the admins has lost his rights less than five minutes ago" do
      before do
        @membership = Membership.with_past.find_by_user_and_group user, @corporation.aktivitas.admins_parent
        @membership.valid_from = 1.year.ago
        @membership.valid_to = 4.minutes.ago
        @membership.save
      end
      he { User.find(user.id).should be_able_to :update_memberships, @corporation.aktivitas.admins_parent }
    end

    describe "if the admins has lost his rights more than five minutes ago" do
      before do
        @membership = Membership.with_past.find_by_user_and_group user, @corporation.aktivitas.admins_parent
        @membership.valid_from = 1.year.ago
        @membership.valid_to = 6.minutes.ago
        @membership.save
      end
      he { should_not be_able_to :update_memberships, @corporation.aktivitas.admins_parent }
    end
  end

  describe "Lokaler Seiten-Admin, z.B. für die Rubrik Wingolfsblätter" do
    before do
      @page = create :page
      @page.assign_admin user
      @subpage = @page.child_pages.create title: "Subpage"
      @attachment = @subpage.attachments.create title: "Some Document"
    end

    he { should be_able_to :manage, @page }
    he { should be_able_to :manage, @subpage }
    he { should be_able_to :manage, @attachment }
  end

  describe "(Semesterprogramme)" do
    before do
      @corporation = create :wingolf_corporation
      @term = Term.by_year_and_type Time.zone.now.year, "Terms::Summer"
      @semester_calendar = @corporation.semester_calendars.create term_id: @term.id
      @pdf = @semester_calendar.attachments.create
      @internal_event = create :event, publish_on_local_website: false, publish_on_global_website: false
      @public_event = create :event, publish_on_local_website: true
    end

    describe "Der Senior" do
      before do
        @corporation.aktivitas.create_officer_group(name: "Senior").assign_user user
      end

      he { should be_able_to :create_semester_calendar_for, @corporation }
      he { should be_able_to :update, @semester_calendar }
      he { should_not be_able_to :destroy, @semester_calendar }
      he "should be able to destroy the semester calendar if it has no attachment" do
        @semester_calendar.attachments.first.destroy
        the_user.should be_able_to :destroy, @semester_calendar
      end
      he { should be_able_to :create_attachment_for, @semester_calendar }
      he { should_not be_able_to :destroy, @pdf }
    end

    describe "Ein anderer Wingolfit" do
      before do
        @other_corporation = create :wingolf_corporation
        @other_corporation.status_groups.first.assign_user user
      end

      he { should be_able_to :read, @corporation }
      he { should be_able_to :read, @semester_calendar }
      he { should be_able_to :read, @semester_calendar.attachments.first }
      he { should be_able_to :download, @semester_calendar.attachments.first }
    end

    describe "Irgendein Internetbenutzer" do
      before { user.account.destroy; user.reload }
      he { should be_able_to :read, @semester_calendar }
      he { should be_able_to :read, @public_event }
      he { should_not be_able_to :read, @internal_event }
      he { should be_able_to :read, @semester_calendar.attachments.first }
      he { should be_able_to :download, @semester_calendar.attachments.first }
    end
  end

  describe "(Amtsträger eintragen)" do
    before do
      @corporation = create :wingolf_corporation
      @aktivitas = @corporation.aktivitas
      @senior_group = @aktivitas.create_officer_group name: "Senior"
    end

    describe "Der Senior" do
      before do
        @senior_group.assign_user user
      end
      specify "sollte nicht neue Amtsträger eintragen können" do
        subject.should_not be_able_to :update_memberships, @senior_group
      end
      specify "sollte keine neuen Ämter anlegen können" do
        subject.should_not be_able_to :create_officer_group_for, @aktivitas
      end
      specify "sollte nicht die Ämterhistorie bearbeiten können" do
        subject.should_not be_able_to :index_memberships, @senior_group
      end
    end

    describe "Der lokale Admin" do
      before do
        @aktivitas.assign_admin user
      end
      specify "sollte neue Amtsträger eintragen können" do
        subject.should be_able_to :update_memberships, @senior_group
      end
      specify "sollte neuen Ämter anlegen können" do
        subject.should be_able_to :create_officer_group_for, @aktivitas
      end
      specify "sollte die Ämterhistorie bearbeiten können" do
        subject.should be_able_to :index_memberships, @senior_group
      end
    end
  end

end