class GroupsController < ApplicationController
  respond_to :html, :json, :csv
  load_and_authorize_resource

  def index
    point_navigation_to Page.intranet_root
    respond_with @groups
  end

  def index_mine
    point_navigation_to current_user
    @groups = current_user.groups
    respond_with @groups
  end

  def show
    if @group
      if request.format.html?
        point_navigation_to @group

        # If this is a collection group, e.g. the corporations_parent group,
        # do not list the single members.
        if @group.child_group_ids.count > 15
          @members = nil
          @child_groups = @group.child_groups - [@group.find_officers_parent_group]
        else
          @members = @group.members.order(:last_name, :first_name)
          @members = @members.page(params[:page]).per_page(25) # pagination
        end

        # On collection groups, e.g. the corporations_parent group, only the
        # groups should be shown on the map. These groups have a lot of
        # child groups with address profile fields.
        #
        if child_groups_map_profile_fields.count > 0
          @users_map_profile_fields = []
          @groups_map_profile_fields = child_groups_map_profile_fields
        elsif child_groups_map_profile_fields.count == 0

          # To prevent long loading times, users map profile fields should only
          # be loaded when there are not too many.
          #
          # TODO: Remove this when the map addresses are cached.
          # TODO: Cache map address fields.
          #
          if @group.member_ids.count < 100  # arbitrary limit.
            @users_map_profile_fields = users_map_profile_fields
          else
            @users_map_profile_fields = []
          end

          # Only if there are descendant group address fields, fill the variable
          # for the large map. If there is only the own address, the view
          # will render a small map instead of the large one.
          #
          if descendant_groups_map_profile_fields.count > 0
            @groups_map_profile_fields = own_map_profile_fields + descendant_groups_map_profile_fields
          else
            @groups_map_profile_fields = []
          end

        end

        # TODO: Make this more efficient.
        # This can be done by using @user_map_profile_fields and @group_map_profile_fields
        # separately when creating the map, because then, there is no need to check the
        # type of the profileable.
        # But, this makes no sense at the moment, since the profileable objects have
        # to be loaded anyway, since we need the title of the profileables.
        #
        @large_map_address_fields = @users_map_profile_fields + @groups_map_profile_fields

        # @posts = @group.posts.order("sent_at DESC").limit(10)
        @new_user_group_membership = @group.build_membership
      end
    end

    time = Time.new

    respond_to do |format|
      format.html
      format.csv do
        # See: http://railscasts.com/episodes/362-exporting-csv-and-excel
        send_data @group.members_to_csv(params[:list]), :filename => @group.title.tr(' ', '_') + "_" + I18n.t(params[:list]).tr(' ', '_') + "_" + time.strftime("%Y-%m-%d_%H-%M-%S") + ".csv"
      end
    end

    metric_logger.log_event @group.try(:attributes), type: :show_group
  end

  def update
    @group.update_attributes(group_params)
    respond_with @group
  end

  def create
    if secure_parent_type.present? && params[:parent_id].present?
      @parent = secure_parent_type.constantize.find(params[:parent_id]).child_groups
    else
      @parent = Group
    end
    if can? :manage, @parent
      @new_group = @parent.create(name: I18n.t(:new_group))
    end
    respond_with @new_group
  end

  private

  # This method returns the request parameters and their values as long as the user
  # is permitted to change them.
  #
  # This mechanism protects from mass assignment hacking and replaces the old
  # attr_accessible mechanism.
  #
  # For more information, have a look at these resources:
  #   https://github.com/rails/strong_parameters/
  #   http://railscasts.com/episodes/371-strong-parameters
  #
  def group_params
    if can? :manage, @group
      params.require(:group).permit(:name, :token, :internal_token, :extensive_name)  # TODO: Additionally needed?
    elsif can? :update, @group
      params.require(:group).permit(:name, :token, :internal_token, :extensive_name)
    end
  end

  # These methods collect the address fields for displaying the large map
  # on group pages.
  #
  # https://github.com/apneadiving/Google-Maps-for-Rails/wiki/Controller
  #
  def descendant_groups_map_profile_fields
    @descendant_groups_map_profile_fields ||= ProfileField.where( type: "ProfileFieldTypes::Address", profileable_type: "Group", profileable_id: @group.descendant_group_ids )
  end
  def child_groups_map_profile_fields
    @child_groups_map_profile_fields ||= ProfileField.where( type: "ProfileFieldTypes::Address", profileable_type: "Group", profileable_id: @group.child_group_ids )
  end
  def own_map_profile_fields
    @own_map_profile_fields ||= ProfileField.where( type: "ProfileFieldTypes::Address", profileable_type: "Group", profileable_id: @group.id )
  end
  def users_map_profile_fields
    @users_map_profile_fields ||= ProfileField.where( type: "ProfileFieldTypes::Address", profileable_type: "User", profileable_id: @group.member_ids ).includes(:profileable).select{|address| can?(:read, address) && address.profileable.alive?}
  end


  def secure_parent_type
    params[:parent_type] if params[:parent_type].in? ['Group', 'Page']
  end

end
