class Charts::TermInfos::AlleWingolfitenController < ChartsController

  # GET /charts/term_infos/alle_wingolfiten/anzahl_per_semester.json
  #
  def anzahl_per_semester
    authorize! :index, :charts

    render json: [{
      name: "Gesamt-Anzahl aller Wingolfiten",
      data: Hash[Terms::Year.all.collect { |term| [term.title, ::TermInfos::AlleWingolfiten.for_term(term).number_of_members] }]
    }]
  end

  # GET /charts/term_infos/alle_wingolfiten/zuwaechse_und_abgaenge_per_semester.json
  #
  def zuwaechse_und_abgaenge_per_semester
    authorize! :index, :charts

    render json: [
      {
        name: "Aktivmeldungen",
        data: Hash[Terms::Year.all.collect { |term| [term.title, ::TermInfos::AlleWingolfiten.for_term(term).anzahl_aktivmeldungen] }]
      },
      {
        name: "Aktivmeldungen-Soll (120/Jahr) für langfristig stabile Mitgliederzahl (Weibezahn-Studie) bei 49% Austritten",
        data: Hash[Terms::Year.all.collect { |term| [term.title, 120] }]
      },
      {
        name: "Todesfälle (negativ aufgetragen)",
        data: Hash[Terms::Year.all.collect { |term| [term.title, - ::TermInfos::AlleWingolfiten.for_term(term).anzahl_todesfaelle] }]
      },
      {
        name: "Austritte und Streichungen (negativ aufgetragen)",
        data: Hash[Terms::Year.all.collect { |term| [term.title, - ::TermInfos::AlleWingolfiten.for_term(term).anzahl_austritte] }]
      },
      {
        name: "Bilanz",
        data: Hash[Terms::Year.all.collect { |term| [term.title, ::TermInfos::AlleWingolfiten.for_term(term).balance] }]
      }
    ]
  end

end