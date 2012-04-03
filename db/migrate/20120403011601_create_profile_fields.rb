class CreateProfileFields < ActiveRecord::Migration
  def change
    create_table :profile_fields do |t|
      t.integer     :user_id
      t.string      :label
      t.string      :type
      t.string      :value
#      t.integer     :composite_id # "die id des Profilfeldes, das diesen Eintrag als Komponente eines Verbunds enthaelt, z.B. fuer Beschaeftigungsverhaeltnisse, die aus Zeitraum, Arbeitgeber, Position, etc. bestehen." # Das habe ich jetzt erstmal weggelassen, weil ich noch nicht weiß, ob es geschickte Struktur-Abstraktionen gibt.
      t.timestamps
    end
  end
end
