class Charts::TermReports::AktiveUndPhilisterController < ChartsController

  # GET /charts/term_reports/aktive_und_philister/anzahl_per_jahr.json?corporation_id=12
  #
  def anzahl_per_jahr
    authorize! :index, :charts

    # Die letzten zehn Jahre
    term_ids = Terms::Year.where(year: (Time.zone.now.year-10)..Time.zone.now.year).pluck(:id)

    render json: [
      {
        name: "Philister",
        data: Hash[corporation.term_reports.where(term_id: term_ids).collect { |term_report| [term_report.term.title, term_report.anzahl_philister] }]
      },
      {
        name: "Aktive",
        data: Hash[corporation.term_reports.where(term_id: term_ids).collect { |term_report| [term_report.term.title, term_report.anzahl_aller_aktiven] }]
      }
    ]
  end

  private

  def corporation
    Corporation.find params[:corporation_id]
  end

end