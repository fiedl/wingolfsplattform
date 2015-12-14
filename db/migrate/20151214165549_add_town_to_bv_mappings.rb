class AddTownToBvMappings < ActiveRecord::Migration
  def change
    add_column :bv_mappings, :town, :string
  end
end
