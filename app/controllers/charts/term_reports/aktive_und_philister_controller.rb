class Charts::TermReports::AktiveUndPhilisterController < ChartsController

  # https://railscasts.com/episodes/259-decent-exposure
  #
  expose :corporation
  expose :terms, -> {
    # Wir zeigen hier willkürlich die letzten zehn Jahre an.
    Terms::Year.where(year: (Time.zone.now.year-10)..Time.zone.now.year)
  }
  expose :term_reports, -> {
    terms.collect { |term| ::TermReports::ForCorporation.by_corporation_and_term(corporation, term) }
  }

  # GET /charts/term_reports/aktive_und_philister/anzahl_per_jahr.json?corporation_id=12
  #
  def anzahl_per_jahr
    authorize! :index, :charts

    render json: [
      {
        name: "Philister",
        data: Hash[term_reports.collect { |term_report| [term_report.term.title, term_report.anzahl_philister] }]
      },
      {
        name: "Aktive",
        data: Hash[term_reports.collect { |term_report| [term_report.term.title, term_report.anzahl_aller_aktiven] }]
      }
    ]
  end

end