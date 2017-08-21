require 'spec_helper'

describe TermReports::ForCorporation do
  before do
    @term = Terms::Winter.create year: 2016

    @corporation = create :wingolf_corporation
    @semester_calendar = @corporation.semester_calendars.create term_id: @term.id
    @event = @corporation.events.create name: "Winter party", start_at: "2016-12-01".to_datetime

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

    @term_report = @corporation.term_reports.create term_id: @term.id
    @term_report = TermReport.find @term_report.id  # In order for it to have the proper sub class.
  end

  describe "#fill_info" do
    subject { @term_report.fill_info }

    it "should fill in the statistical info correctly" do
      subject
      @term_report.anzahl_aktivmeldungen.should == [@hospitant].count
      @term_report.anzahl_aller_aktiven.should == [@hospitant, @krassfux, @brandfux, @aktiver_bursch, @inaktiver_bursch_loci, @inaktiver_bursch_nun_loci, @konkneipant].count
      @term_report.anzahl_burschungen.should == [@aktiver_bursch].count
      @term_report.anzahl_burschen.should == [@aktiver_bursch, @inaktiver_bursch_loci, @inaktiver_bursch_non_loci].count
      @term_report.anzahl_fuxen.should == [@krassfux, @brandfux].count
      @term_report.anzahl_aktiver_burschen.should == [@aktiver_bursch].count
      @term_report.anzahl_inaktiver_burschen_loci.should == [@inaktiver_bursch_loci].count
      @term_report.anzahl_inaktiver_burschen_non_loci.should == [@inaktiver_bursch_non_loci].count
      @term_report.anzahl_konkneipwanten.should == [@konkneipant].count
      @term_report.anzahl_philistrationen.should == [@philister].count
      @term_report.anzahl_philister.should == [@philister].count
      @term_report.anzahl_austritte.should == [@ausgetretener_aktiver, @ausgetretener_philister].count
      @term_report.anzahl_austritte_aktive.should == [@ausgetretener_aktiver].count
      @term_report.anzahl_austritte_philister.should == [@gestrichener_philister].count
      @term_report.anzahl_todesfaelle.should == [@verstorbener].count
    end
  end
end