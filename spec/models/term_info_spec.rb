require 'spec_helper'

describe TermInfo do
  before do
    @term = Terms::Winter.create year: 2016

    @corporation = create :wingolf_corporation
    @semester_calendar = @corporation.semester_calendars.create year: 2016, term: :winter_term
    @event = @corporation.child_events.create title: "Winter party", start_at: "2016-12-01".to_datetime

    @hospitant = create :user
    @corporation.status_group("Hospitanten").assign_user @hospitant, at: "2016-12-01".to_date

    @krassfux = create :user
    @corporation.status_group("Hospitanten").assign_user @krassfux, at: "2016-07-15".to_date
    @krassfux.memberships.last.move_to @corporation.status_group("Kraßfuxen"), at: "2016-12-05".to_date

    @brandfux = create :user
    @corporation.status_group("Hospitanten").assign_user @brandfux, at: "2015-01-15".to_date
    @brandfux.memberships.last.move_to @corporation.status_group("Kraßfuxen"), at: "2015-06-12".to_date
    @brandfux.memberships.last.move_to @corporation.status_group("Brandfuxen"), at: "2016-11-30".to_date

    @aktiver_bursch = create :user
    @corporation.status_group("Hospitanten").assign_user @aktiver_bursch, at: "2015-01-01".to_date
    @aktiver_bursch.memberships.last.move_to @corporation.status_group("Kraßfuxen"), at: "2015-05-12".to_date
    @aktiver_bursch.memberships.last.move_to @corporation.status_group("Brandfuxen"), at: "2016-10-20".to_date
    @aktiver_bursch.memberships.last.move_to @corporation.status_group("Aktive Burschen"), at: "2017-01-12".to_date

    @inaktiver_bursch_loci = create :user
    @corporation.status_group("Hospitanten").assign_user @inaktiver_bursch_loci, at: "2015-01-01".to_date
    @inaktiver_bursch_loci.memberships.last.move_to @corporation.status_group("Kraßfuxen"), at: "2014-05-12".to_date
    @inaktiver_bursch_loci.memberships.last.move_to @corporation.status_group("Brandfuxen"), at: "2015-10-20".to_date
    @inaktiver_bursch_loci.memberships.last.move_to @corporation.status_group("Aktive Burschen"), at: "2016-01-12".to_date
    @inaktiver_bursch_loci.memberships.last.move_to @corporation.status_group("Inaktive Burschen loci"), at: "2016-10-16".to_date

    @inaktiver_bursch_non_loci = create :user
    @corporation.status_group("Hospitanten").assign_user @inaktiver_bursch_non_loci, at: "2015-01-01".to_date
    @inaktiver_bursch_non_loci.memberships.last.move_to @corporation.status_group("Kraßfuxen"), at: "2014-05-12".to_date
    @inaktiver_bursch_non_loci.memberships.last.move_to @corporation.status_group("Brandfuxen"), at: "2015-10-20".to_date
    @inaktiver_bursch_non_loci.memberships.last.move_to @corporation.status_group("Aktive Burschen"), at: "2016-01-12".to_date
    @inaktiver_bursch_non_loci.memberships.last.move_to @corporation.status_group("Inaktive Burschen non loci"), at: "2016-10-16".to_date

    @konkneipant = create :user
    @corporation.status_group("Konkneipanten").assign_user @konkneipant, at: "2015-02-16".to_date

    @philister = create :user
    @corporation.status_group("Hospitanten").assign_user @philister, at: "2005-01-01".to_date
    @philister.memberships.last.move_to @corporation.status_group("Kraßfuxen"), at: "2005-05-12".to_date
    @philister.memberships.last.move_to @corporation.status_group("Brandfuxen"), at: "2005-10-20".to_date
    @philister.memberships.last.move_to @corporation.status_group("Aktive Burschen"), at: "2006-01-12".to_date
    @philister.memberships.last.move_to @corporation.status_group("Philister"), at: "2016-10-31".to_date

    @ausgetretener_aktiver = create :user
    @corporation.status_group("Hospitanten").assign_user @ausgetretener_aktiver, at: "2015-01-01".to_date
    @ausgetretener_aktiver.memberships.last.move_to @corporation.status_group("Schlicht Ausgetretene"), at: "2016-12-14".to_date

    @gestrichener_philister = create :user
    @corporation.status_group("Philister").assign_user @gestrichener_philister, at: "2015-01-01".to_date
    @gestrichener_philister.memberships.last.move_to @corporation.status_group("Gestrichene"), at: "2016-12-14".to_date

    @verstorbener = create :user
    @corporation.status_group("Philister").assign_user @verstorbener, at: "1947-01-01".to_date
    @verstorbener.mark_as_deceased at: "2016-11-19".to_date

    @term_info = @term.term_infos.create corporation_id: @corporation.id
  end

  describe "after #fill_info" do
    before { @term_info.fill_info }

    describe "#anzahl_aktivmeldungen" do
      subject { @term_info.anzahl_aktivmeldungen }
      it { should == [@hospitant].count }
    end

    describe "#anzahl_aller_aktiven" do
      subject { @term_info.anzahl_aller_aktiven }
      it { should == [@hospitant, @krassfux, @brandfux, @aktiver_bursch, @inaktiver_bursch_loci, @inaktiver_bursch_nun_loci, @konkneipant].count }
    end

    describe "#anzahl_burschungen" do
      subject { @term_info.anzahl_burschungen }
      it { should == [@aktiver_bursch].count }
    end

    describe "#anzahl_burschen" do
      subject { @term_info.anzahl_burschen }
      it { should == [@aktiver_bursch, @inaktiver_bursch_loci, @inaktiver_bursch_non_loci].count }
    end

    describe "#anzahl_fuxen" do
      subject { @term_info.anzahl_fuxen }
      it { should == [@krassfux, @brandfux].count }
    end

    describe "#anzahl_aktiver_burschen" do
      subject { @term_info.anzahl_aktiver_burschen }
      it { should == [@aktiver_bursch].count }
    end

    describe "#anzahl_inaktiver_burschen_loci" do
      subject { @term_info.anzahl_inaktiver_burschen_loci }
      it { should == [@inaktiver_bursch_loci].count }
    end

    describe "#anzahl_inaktiver_burschen_non_loci" do
      subject { @term_info.anzahl_inaktiver_burschen_non_loci }
      it { should == [@inaktiver_bursch_non_loci].count }
    end

    describe "#anzahl_konkneipwanten" do
      subject { @term_info.anzahl_konkneipwanten }
      it { should == [@konkneipant].count }
    end

    describe "#anzahl_philistrationen" do
      subject { @term_info.anzahl_philistrationen }
      it { should == [@philister].count }
    end

    describe "#anzahl_philister" do
      subject { @term_info.anzahl_philister }
      it { should == [@philister].count }
    end

    describe "#anzahl_austritte" do
      subject { @term_info.anzahl_austritte }
      it { should == [@ausgetretener_aktiver].count }
    end

    describe "#anzahl_austritte_aktive" do
      subject { @term_info.anzahl_austritte_aktive }
      it { should == [@ausgetretener_aktiver].count }
    end

    describe "#anzahl_austritte_philister" do
      subject { @term_info.anzahl_austritte_philister }
      it { should == [@gestrichener_philister].count }
    end

    describe "#anzahl_todesfaelle" do
      subject { @term_info.anzahl_todesfaelle }
      it { should == [@verstorbener].count }
    end

  end
end