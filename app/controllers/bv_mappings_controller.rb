class BvMappingsController < ApplicationController

  before_action :set_nav_info

  # https://railscasts.com/episodes/259-decent-exposure
  #
  expose :bv_mappings, -> { BvMapping.all }
  expose :new_bv_mapping, -> { BvMapping.new(params[:bv_mapping]) }
  expose :all_bv_names, -> { Bv.pluck(:token).uniq }

  def index
    authorize! :index, BvMapping
  end

  def create
    authorize! :create, BvMapping

    if existing_mapping = BvMapping.find_by(plz: bv_mapping_params[:plz], town: bv_mapping_params[:town])
      flash[:error] = "Die Zuordnung #{bv_mapping_params.to_s} konnte nicht angelegt werden, weil schon die Zuordnung #{existing_mapping.attributes.to_s} existiert."
    else
      BvMapping.create! bv_mapping_params
      flash[:error] = nil
      flash[:notice] = "Die Zuordnung #{bv_mapping_params.to_s} wurde erfolgreich eingetragen. Es erfolgt aber keine automatische Neuzuordnung! Bitte lege bei Philistern, die diese Zuordnung betrifft, die Adresse einfach neu an. Falls es sich um mehr als einen Philister handelt, wende Dich bitte an support@wingolf.io."
    end

    render action: :index
  end

  private

  def bv_mapping_params
    params.require(:bv_mapping).permit(:plz, :town, :bv_name).each { |key, value| value.strip! } if can? :create, BvMapping
  end

  def set_nav_info
    set_current_title "BV-Ort-Zuordnungen"
    set_current_access :admin
    set_current_access_text :only_global_admins_can_access_this
    set_current_breadcrumbs [
      {title: current_title}
    ]
  end

end