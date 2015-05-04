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
      @wingolfsseminar_page = Page.intranet_root.child_pages.create name: "Wingolfsseminar"  # no author!
      @wingolfsseminar_page.update_attribute :created_at, 10.days.ago
      @seminarbeauftragter_group = @wingolfsseminar_page.officers_parent.child_groups.create name: "Seminarbeauftragter des Wingolfs"
      @seminarbeauftragter_group << user
    end
    he { should be_able_to :update, @wingolfsseminar_page }
    he { should_not be_able_to :destroy, @wingolfsseminar_page }
    
    he "should be able to create and update a sub-page" do
      the_user.should be_able_to :create_page_for, @wingolfsseminar_page
      
      @sub_page = @wingolfsseminar_page.child_pages.create name: "Sub Page"
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
          @seminar_event = Group.alle_wingolfiten.child_events.create name: "75. Wingolfsseminar"
          @seminar_event.contact_people_group.child_users << user
        end
        
        he { should be_able_to :update, @seminar_event }
        he { should be_able_to :create_attachment_for, @seminar_event }
        he { should be_able_to :create_page_for, @seminar_event }

        describe "Wenn er eine Unterseite mit Tagungsunterlagen erstellt hat" do
          before do
            @tagungsunterlagen_page = @seminar_event.child_pages.create name: "Tagungsunterlagen"
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
      @protokolle_page = @phr_group.child_pages.create name: "Protokolle"
      @protokoll_attachment = @protokolle_page.attachments.create name: "Protokoll"
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
          @protokoll_attachment = @protokolle_page.attachments.create name: "Protokoll"
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
      @wbl_page = Page.intranet_root.child_pages.create name: "Wingolfsblätter"
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
        @wbl_2014_page = @wbl_page.child_pages.create name: "Wingolfsblätter 2014"
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
        @wbl_2015_page = @wbl_page.child_pages.create name: "Wingolfsblätter 2015"
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
    he { should_not be_able_to :create_attachment_for, @event }
    
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
end