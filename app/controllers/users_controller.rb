# -*- coding: utf-8 -*-
class UsersController < ApplicationController

  respond_to :html, :json, :js

  before_filter :find_user, only: [:show, :update, :forgot_password]
  authorize_resource except: [:forgot_password]

  def index
    begin
      redirect_to group_path(Group.everyone)
    rescue
      raise "No basic groups are present, yet. Try `rake bootstrap:all`."
    end
  end

  def show
    if current_user == @user
      current_user.update_last_seen_activity("sieht sich sein eigenes Profil an", @user)
    else
      current_user.try(:update_last_seen_activity, "sieht sich das Profil von #{@user.title} an", @user)
    end
    
    respond_to do |format|
      format.html # show.html.erb
                  #format.json { render json: @profile.sections }  # TODO
    end
    metric_logger.log_event @user.attributes.merge({name: @user.name, title: @user.title}), type: :show_user
  end

  def new
    @title = "Aktivmeldung eintragen" # t(:create_user)
    @user = User.new

    @group = Group.find(params[:group_id]) if params[:group_id]
    @user.add_to_corporation = @group.becomes(Corporation).id if @group && @group.corporation?

    @user.alias = params[:alias]
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      @user.send_welcome_email if @user.account
      @user.fill_in_template_profile_information
      redirect_to @user
    else
      @title = t :create_user
      @user.valid?
      render :action => "new"
    end
  end

  def update
    @user.update_attributes(params[:user])
    respond_with @user
  end

  def autocomplete_title
    query = params[:term] if params[ :term ]
    query ||= params[ :query ] if params[ :query ]
    query ||= ""
    
    @users = User.where("CONCAT(first_name, ' ', last_name) LIKE ?", "%#{query}%")

    # render json: json_for_autocomplete(@users, :title)
    # render json: @users.to_json( :methods => [ :title ] )
    render json: @users.map(&:title)
  end

  def forgot_password
    authorize! :update, @user.account
    @user.account.send_new_password
    flash[:notice] = I18n.t(:new_password_has_been_sent_to, user_name: @user.title)
    redirect_to :back
  end

  private

  def find_user
    if not handle_mystery_user
      @user = User.find(params[:id]) if params[:id].present?
      @user ||= User.find_by_alias(params[:alias]) if params[:alias].present?
      @user ||= User.new
      @title = @user.title
      @navable = @user
    end
  end
  
  def handle_mystery_user
    if (params[:id].to_i == 1) and (not User.where(id: 1).present?)
      redirect_to group_path(Group.everyone), :notice => "I bring order to chaos. I am the beginning, the end, the one who is many."
      return true
    end
  end

end
