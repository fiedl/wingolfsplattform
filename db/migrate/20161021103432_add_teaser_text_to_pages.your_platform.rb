# This migration comes from your_platform (originally 20161016193501)
class AddTeaserTextToPages < ActiveRecord::Migration
  def change
    add_column :pages, :teaser_text, :text
  end
end
