class BvMappingsController < ApplicationController

  # https://railscasts.com/episodes/259-decent-exposure
  #
  expose :bv_mappings, -> { BvMapping.all }

  def index
    authorize! :index, BvMapping

    set_current_title "BV-Ort-Zuordnungen"
    set_current_access :admin
    set_current_access_text :only_global_admins_can_access_this
    set_current_breadcrumbs [
      {title: current_title}
    ]
  end

end