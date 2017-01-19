class AddAnzahlErstbandtraegerToTermInfos < ActiveRecord::Migration
  def change
    add_column :term_infos, :anzahl_erstbandtraeger_aktivitas, :integer
    add_column :term_infos, :anzahl_erstbandtraeger_philisterschaft, :integer
  end
end
