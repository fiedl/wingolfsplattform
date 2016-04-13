require 'importers/models/log'
require 'colored'

namespace :import do

  desc "Import BVs and BV-PLZ mappings."
  task :bvs => [
    'environment',
    'bootstrap:all',
    'bvs:print_info',
    'bvs:import_basic_bv_mappings',
    'bvs:import_bv_groups',
    'bvs:additional_mappings'
  ]

  namespace :bvs do

    task :print_info do
      log.head "Importing BVs and BV-PLZ mappings."
    end

    task :clear => [:environment, :print_info] do
      log.section "Bisherige BV-Zuordnungen leeren"
      log.info "Entferne #{BvMapping.all.count} Zuordnungen."
      BvMapping.destroy_all
      log.info "Fertig."
    end

    task :import_basic_bv_mappings => [:environment, :print_info] do
      log.section "BV-Zuordnungen aus Tabelle importieren."
      log.info "Datenquelle: https://raw.githubusercontent.com/fiedl/wingolfsplattform/master/import/groups_bv_zuordnung.csv"

      if BvMapping.count > 0
        log.info "BV-Zuordnungen bereits vorhanden. Überspringe diesen Vorgang."
        log.info "Für erneuten Import bitte vorher 'rake import:bvs:clear' aufrufen."
      else
        log.info "Das wird einige Minuten dauern."

        require 'csv'
        file_name = File.join( Rails.root, "import", "groups_bv_zuordnung.csv" )
        if File.exists? file_name
          counter = 0
          CSV.foreach file_name, headers: true, col_sep: ';' do |row|
            BvMapping.create bv_name: row['BV'], plz: row['PLZ'], town: row['Wohnort'].strip
            counter += 1
          end
          log.success "#{counter} BV-Zuordnungen importiert."
        else
          log.error "Datei nicht vorhanden: import/groups_bv_zuordnung.csv"
        end

      end
    end

    task :import_bv_groups => [:environment, :print_info] do
      log.section "BV-Gruppen importieren"
      if Group.bvs_parent.child_groups.count > 1
        log.info "BV-Gruppen sind bereits vorhanden. Überspringe den erneuten Import."
      else
        Group.csv_import_groups_into_parent_group "groups_bvs.csv", Group.bvs_parent
        log.info "Fertig. Es gibt nun #{Group.bvs_parent.child_groups.count} BV-Gruppen."
      end
    end

    task :additional_mappings => [:environment, :print_info] do
      log.section "Ergänzungen zu BV-Zuordnungen importieren."

      # 2016-04-13, Fiedlschuster
      # Ergänzende Informationen von Neusel.
      #
      # Die folgende Vorlage wurde erstellt per
      # be rake import:bvs:clear import:bvs fix:bvs
      #
      # Siehe auch: https://trello.com/c/GynIkAfo/945-bvs-durch-stadte-namen-und-plz-definieren-2015-iph7haim
      #
      BvMapping.find_or_create plz: '01067', town: 'Dresden', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01069', town: 'Dresden', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01099', town: 'Dresden', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01127', town: 'Dresden', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01129', town: 'Dresden', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01139', town: 'Dresden', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01157', town: 'Dresden', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01189', town: 'Dresden', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01219', town: 'Dresden', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01277', town: 'Dresden', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01307', town: 'Dresden', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01309', town: 'Dresden', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01328', town: 'Dresden', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01454', town: 'Radeberg', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01458', town: 'Ottendorf-Okrilla', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01809', town: 'Dohna', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01844', town: 'Neustadt in Sachsen', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01906', town: 'Burkau', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04103', town: 'Leipzig', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04107', town: 'Leipzig', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04109', town: 'Leipzig', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04155', town: 'Leipzig', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04159', town: 'Leipzig', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04177', town: 'Leipzig', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04179', town: 'Leipzig', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04229', town: 'Leipzig', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04275', town: 'Leipzig', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04299', town: 'Leipzig', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04315', town: 'Leipzig', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04317', town: 'Leipzig', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04416', town: 'Markkleeberg', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04420', town: 'Markranstädt', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04442', town: 'Zwenkau', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04509', town: 'Delitzsch', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04509', town: 'Krostitz', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04600', town: 'Altenburg', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '04655', town: 'Kohren-Sahlis', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04720', town: 'Döbeln', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04862', town: 'Mockrehna', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04886', town: 'Beilrode', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04895', town: 'Falkenberg/Elster', bv_name: 'BV 01'
      BvMapping.find_or_create plz: '06108', town: 'Halle', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06110', town: 'Halle', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06112', town: 'Halle', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06114', town: 'Halle', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06116', town: 'Halle', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06118', town: 'Halle', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06120', town: 'Halle', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06179', town: 'Salzatal', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06193', town: 'Wettin-Löbejün', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06217', town: 'Merseburg', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06268', town: 'Barnstädt', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06333', town: 'Arnstedt', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06343', town: 'Mansfeld', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06493', town: 'Ballenstedt', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06543', town: 'Sangerhausen', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06567', town: 'Bad Frankenhausen', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '06618', town: 'Naumburg', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06647', town: 'Bad Bibra', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06648', town: 'Eckartsberga', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06779', town: 'Retzau', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06844', town: 'Dessau-Roßlau', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06846', town: 'Dessau-Roßlau', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06862', town: 'Dessau-Roßlau', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06886', town: 'Wittenberg', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '07381', town: 'Pössneck', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '07407', town: 'Remda-Teichel', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '07546', town: 'Gera', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '07743', town: 'Jena', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '07745', town: 'Jena', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '07747', town: 'Jena', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '07749', town: 'Jena', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '07751', town: 'Bucha', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '07751', town: 'Jena', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '07926', town: 'Gefell', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '07955', town: 'Auma-Weidatal', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '08064', town: 'Zwickau', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '08312', town: 'Lauter-Bernsbach', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '08340', town: 'Schwarzenberg/Erzgebirge', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '08451', town: 'Crimmitschau', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09116', town: 'Chemnitz', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09123', town: 'Chemnitz', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09126', town: 'Chemnitz', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09127', town: 'Chemnitz', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09130', town: 'Chemnitz', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09217', town: 'Burgstädt', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09353', town: 'Oberlungwitz', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09434', town: 'Zschopau', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09517', town: 'Zöblitz', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09618', town: 'Brand-Erbisdorf', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '14974', town: 'Trebbin', bv_name: 'BV 01'
      BvMapping.find_or_create plz: '15230', town: 'Frankfurt an der Oder', bv_name: 'BV 01'
      BvMapping.find_or_create plz: '15234', town: 'Frankfurt an der Oder', bv_name: 'BV 01'
      BvMapping.find_or_create plz: '16827', town: 'Neuruppin', bv_name: 'BV 01'
      BvMapping.find_or_create plz: '17349', town: 'Lindetal', bv_name: 'BV 06'
      BvMapping.find_or_create plz: '18375', town: 'Wieck auf dem Darß', bv_name: 'BV 06'
      BvMapping.find_or_create plz: '23689', town: 'Ratekau', bv_name: 'BV 03'
      BvMapping.find_or_create plz: '24223', town: 'Schwentinental', bv_name: 'BV 03'
      BvMapping.find_or_create plz: '27607', town: 'Geestland', bv_name: 'BV 04'
      BvMapping.find_or_create plz: '27637', town: 'Wurster Nordseeküste', bv_name: 'BV 04'
      BvMapping.find_or_create plz: '30159', town: 'Hanover', bv_name: 'BV 08'
      BvMapping.find_or_create plz: '30161', town: 'Hanover', bv_name: 'BV 08'
      BvMapping.find_or_create plz: '30165', town: 'Hanover', bv_name: 'BV 08'
      BvMapping.find_or_create plz: '30167', town: 'Hanover', bv_name: 'BV 08'
      BvMapping.find_or_create plz: '30177', town: 'Hanover', bv_name: 'BV 08'
      BvMapping.find_or_create plz: '30419', town: 'Hanover', bv_name: 'BV 08'
      BvMapping.find_or_create plz: '30449', town: 'Hanover', bv_name: 'BV 08'
      BvMapping.find_or_create plz: '30451', town: 'Hanover', bv_name: 'BV 08'
      BvMapping.find_or_create plz: '30455', town: 'Hanover', bv_name: 'BV 08'
      BvMapping.find_or_create plz: '30519', town: 'Hanover', bv_name: 'BV 08'
      BvMapping.find_or_create plz: '30625', town: 'Hanover', bv_name: 'BV 08'
      BvMapping.find_or_create plz: '30629', town: 'Hanover', bv_name: 'BV 08'
      BvMapping.find_or_create plz: '30657', town: 'Hanover', bv_name: 'BV 08'
      BvMapping.find_or_create plz: '30659', town: 'Hanover', bv_name: 'BV 08'
      BvMapping.find_or_create plz: '31785', town: 'Hamelin', bv_name: 'BV 08'
      BvMapping.find_or_create plz: '31787', town: 'Hamelin', bv_name: 'BV 08'
      BvMapping.find_or_create plz: '31789', town: 'Hamelin', bv_name: 'BV 08'
      BvMapping.find_or_create plz: '34454', town: 'Arolsen', bv_name: 'BV 22'
      BvMapping.find_or_create plz: '36199', town: 'Rotenburg an der Fulda', bv_name: 'BV 22'
      BvMapping.find_or_create plz: '37547', town: 'Einbeck', bv_name: 'BV 10'
      BvMapping.find_or_create plz: '39175', town: 'Gommern', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '40885', town: 'Ratingen', bv_name: 'BV 19b'
      BvMapping.find_or_create plz: '53125', town: 'Bonn', bv_name: 'BV 20'
      BvMapping.find_or_create plz: '65549', town: 'Limburg an der Lahn', bv_name: 'BV 24'
      BvMapping.find_or_create plz: '66386', town: 'Sankt Ingbert', bv_name: 'BV 41'
      BvMapping.find_or_create plz: '66606', town: 'Sankt Wendel', bv_name: 'BV 41'
      BvMapping.find_or_create plz: '67256', town: 'Weisenheim am Berg', bv_name: 'BV 40'
      BvMapping.find_or_create plz: '67354', town: 'Römerberg-Dudenhofen', bv_name: 'BV 40'
      BvMapping.find_or_create plz: '67373', town: 'Römerberg-Dudenhofen', bv_name: 'BV 40'
      BvMapping.find_or_create plz: '68789', town: 'Sankt Leon-Rot', bv_name: 'BV 31'
      BvMapping.find_or_create plz: '78112', town: 'Sankt Georgen', bv_name: 'BV 33'
      BvMapping.find_or_create plz: '79837', town: 'Sankt Blasien', bv_name: 'BV 33'
      BvMapping.find_or_create plz: '81373', town: 'München', bv_name: 'BV 38'
      BvMapping.find_or_create plz: '82049', town: 'Pullach im Isartal', bv_name: 'BV 38'
      BvMapping.find_or_create plz: '82362', town: 'Weilheim in Oberbayern', bv_name: 'BV 38'
      BvMapping.find_or_create plz: '83131', town: 'Nußdorf am Inn', bv_name: 'BV 38'
      BvMapping.find_or_create plz: '83371', town: 'Traunreut', bv_name: 'BV 38'
      BvMapping.find_or_create plz: '83565', town: 'Frauenneuharting', bv_name: 'BV 38'
      BvMapping.find_or_create plz: '85521', town: 'Hohenbrunn', bv_name: 'BV 38'
      BvMapping.find_or_create plz: '85551', town: 'Kirchheim bei München', bv_name: 'BV 38'
      BvMapping.find_or_create plz: '85598', town: 'Vaterstetten', bv_name: 'BV 38'
      BvMapping.find_or_create plz: '86911', town: 'Dießen am Ammersee', bv_name: 'BV 38'
      BvMapping.find_or_create plz: '86941', town: 'Eresing', bv_name: 'BV 38'
      BvMapping.find_or_create plz: '88348', town: 'Saulgau', bv_name: 'BV 39'
      BvMapping.find_or_create plz: '90518', town: 'Altdorf bei Nürnberg', bv_name: 'BV 37'
      BvMapping.find_or_create plz: '91077', town: 'Neunkirchen am Brand', bv_name: 'BV 37'
      BvMapping.find_or_create plz: '91413', town: 'Neustadt an der Aisch', bv_name: 'BV 37'
      BvMapping.find_or_create plz: '91623', town: 'Sachsen bei Ansbach', bv_name: 'BV 37'
      BvMapping.find_or_create plz: '91781', town: 'Weißenburg in Bayern', bv_name: 'BV 37'
      BvMapping.find_or_create plz: '92637', town: 'Weiden in der Oberpfalz', bv_name: 'BV 37'
      BvMapping.find_or_create plz: '93086', town: 'Wörth an der Donau', bv_name: 'BV 37'
      BvMapping.find_or_create plz: '96185', town: 'Schönbrunn im Steigerwald', bv_name: 'BV 36'
      BvMapping.find_or_create plz: '97616', town: 'Bad Neustadt an der Saale', bv_name: 'BV 35'
      BvMapping.find_or_create plz: '97647', town: 'Nordheim vor der Rhön', bv_name: 'BV 35'
      BvMapping.find_or_create plz: '97653', town: 'Bischofsheim an der Rhön', bv_name: 'BV 35'
      BvMapping.find_or_create plz: '97816', town: 'Lohr am Main', bv_name: 'BV 35'
      BvMapping.find_or_create plz: '99195', town: 'Erfurt', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '99198', town: 'Erfurt', bv_name: 'BV 28'

      # 2016-04-13
      # Der Testlauf `rake fix:bvs` hat noch Diskrepanzen aufgezeigt,
      # die folgend aufgelöst werden.
      #
      # Neunkirchen am Brand gehört zum BV 37, nicht 36. Beide Einträge waren vorhanden.
      BvMapping.where(plz: '91077', town: 'Neunkirchen a.Brand').destroy_all
      #
      # Die folgenden Korrekturdaten wurden dem alten Anlauf entnommen:
      # https://trello.com/c/VCeC7ne5/586-fehlende-bv-zuordnungen
      # https://github.com/fiedl/wingolfsplattform/commit/1f5c9c4781185947ac87916a5994270aa7d3b985
      #
      # Sofern dort nicht gefunden, dann dem Vademecum:
      # https://wingolfsplattform.org/attachments/285/Vademecum_Wingolfiticum_2012.pdf
      #
      BvMapping.where(plz: '21629').first.update_attributes bv_name: 'BV 05'
      BvMapping.where(plz: '89343').first.update_attributes bv_name: 'BV 38'
      BvMapping.where(plz: '65817').first.update_attributes bv_name: 'BV 26'
      BvMapping.where(plz: '48291').first.update_attributes bv_name: 'BV 12'
      BvMapping.where(plz: '49377').first.update_attributes bv_name: 'BV 04'
      BvMapping.where(plz: '48231').first.update_attributes bv_name: 'BV 12'
      BvMapping.where(plz: '74930').first.update_attributes bv_name: 'BV 31'
      BvMapping.where(plz: '91094').first.update_attributes bv_name: 'BV 37'
      BvMapping.where(plz: '75428').first.update_attributes bv_name: 'BV 34'
      BvMapping.where(plz: '59929').first.update_attributes bv_name: 'BV 22'
      BvMapping.where(plz: '35114').first.update_attributes bv_name: 'BV 24'
      BvMapping.where(plz: '78647').first.update_attributes bv_name: 'BV 34'
      BvMapping.where(plz: '74749').first.update_attributes bv_name: 'BV 34'
      BvMapping.where(plz: '59348').first.update_attributes bv_name: 'BV 12' # Lüdinghausen
      BvMapping.where(plz: '59929').first.update_attributes bv_name: 'BV 22'
      BvMapping.where(plz: '22844').first.update_attributes bv_name: 'BV 02'
      BvMapping.where(plz: '50374').first.update_attributes bv_name: 'BV 20'
      BvMapping.where(plz: '33142').first.update_attributes bv_name: 'BV 16'
      BvMapping.where(plz: '26871').first.update_attributes bv_name: 'BV 11'
      BvMapping.where(plz: '50374').first.update_attributes bv_name: 'BV 20'
      BvMapping.where(plz: '56477').first.update_attributes bv_name: 'BV 21'
      BvMapping.where(plz: '38527').first.update_attributes bv_name: 'BV 09'
      BvMapping.where(plz: '38536').first.update_attributes bv_name: 'BV 09'
      BvMapping.where(plz: '97453').first.update_attributes bv_name: 'BV 36'
      BvMapping.where(plz: '49377').first.update_attributes bv_name: 'BV 04'
      BvMapping.where(plz: '86470').first.update_attributes bv_name: 'BV 38'
      BvMapping.where(plz: '65239').first.update_attributes bv_name: 'BV 26'
      BvMapping.where(plz: '68766').first.update_attributes bv_name: 'BV 32'

      BvMapping.where(plz: '56457', town: 'Westerburg').first.update_attributes bv_name: 'BV 21'
      BvMapping.where(plz: '57627', town: 'Hachenburg').first.update_attributes bv_name: 'BV 21'
      BvMapping.where(plz: '99837', town: 'Dippach').first.update_attributes bv_name: 'BV 24'
      BvMapping.where(plz: '91301', town: 'Forchheim').first.update_attributes bv_name: 'BV 37'
      BvMapping.where(plz: '56290', town: 'Beltheim').first.update_attributes bv_name: 'BV 20'

      BvMapping.find_or_create plz: '85598', town: 'Baldham', bv_name: 'BV 38'
      BvMapping.find_or_create plz: '86941', town: 'St. Ottilien', bv_name: 'BV 38'
      BvMapping.find_or_create plz: '10623', town: 'Berlin-Charlottenburg', bv_name: 'BV 01'
      BvMapping.find_or_create plz: '56605', town: 'Andernach', bv_name: 'BV 20'
      BvMapping.find_or_create plz: '41209', town: 'Mönchengladbach', bv_name: 'BV 19b'
      BvMapping.find_or_create plz: '97631', town: 'Bad Königshofen im Grabfeld', bv_name: 'BV 35'
      BvMapping.find_or_create plz: '21224', town: 'Rosengarten-Tötensen', bv_name: 'BV 02'
      BvMapping.find_or_create plz: '31564', town: 'Nienburg', bv_name: 'BV 08'
      BvMapping.find_or_create plz: '72297', town: 'Seewald-Besenfeld', bv_name: 'BV 34'
      BvMapping.find_or_create plz: '60325', town: 'Frankfurt / Main', bv_name: 'BV 27'
      BvMapping.find_or_create plz: '60325', town: 'Frankfurt/Main', bv_name: 'BV 27'
      BvMapping.find_or_create plz: '99718', town: 'Feldengel-Großenehrich', bv_name: 'BV 28'

      BvMapping.find_or_create plz: '04347', town: 'Leipzig', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '18442', town: 'Neu Lüdershagen', bv_name: 'BV 06'
      BvMapping.find_or_create plz: '26160', town: 'Edewecht', bv_name: 'BV 04'
      BvMapping.find_or_create plz: '29348', town: 'Marwede/Scharnhorst', bv_name: 'BV 07'
      BvMapping.find_or_create plz: '35440', town: 'Großen Linden', bv_name: 'BV 24'
      BvMapping.find_or_create plz: '38678', town: 'Osterrode', bv_name: 'BV 10'
      BvMapping.find_or_create plz: '58675', town: 'Stübecken', bv_name: 'BV 17'
      BvMapping.find_or_create plz: '69214', town: 'Heidelberg', bv_name: 'BV 31'
      BvMapping.find_or_create plz: '73087', town: 'Bad Boll', bv_name: 'BV 34'
      BvMapping.find_or_create plz: '83075', town: 'Bad Aibling', bv_name: 'BV 38'

      ##BvMapping.find_or_create plz: '04838', town: 'Doberschütz', bv_name: 'BV 00'
      ##BvMapping.find_or_create plz: '06295', town: 'Lutherstadt Eisleben', bv_name: 'BV 00'
      ##BvMapping.find_or_create plz: '06333', town: 'Arnstein OT Sylda', bv_name: 'BV 00'

      # Offene Punkte:
      # Fragen, ob folgende Philister im Wunsch-BV (links) sind oder neu zugeordnet (rechts)
      # werden müssen:
      #
      # * (2365) Karsten Kümmel T88 Je Nstft 91, wohnhaft in 49084 Osnabrück: BV 07 -> BV 12
      # * (2778) Reinhard Morgenstern Fr62, wohnhaft in 79361 Sasbach: BV 45 -> BV 33
      # * (2967) Fritz Ulrich Olbricht St79, wohnhaft in 22605 Hamburg: BV 01 -> BV 02
      # * (3517) Karl Helmut Schlösser Si74, wohnhaft in 40723 Hilden: BV 38 -> BV 19b
      # * (4847) Dennis Lohmann Je04, wohnhaft in  Belfast: BV 12 -> BV 45
      # * (4917) André Dürrbeck Fr05 W08, wohnhaft in 81925 München: BV 46 -> BV 38

      # Ältere Anläufe zur Archivierung:
      #
      # # 2014-08-16
      # # Korrektur fehlerhafter Einträge gemäß Vademecum 2005 und 2012.
      # # UserVoice: https://wingolf.uservoice.com/admin/tickets/94
      # # Trello: https://trello.com/c/VCeC7ne5/586-fehlende-bv-zuordnungen

      log.success "Fertig."
    end

  end

  def log
    $log ||= Log.new
  end

end