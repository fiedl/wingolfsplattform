# This extends the your_platform ApplicationController
require_dependency YourPlatform::Engine.root.join('app/controllers/application_controller').to_s

module ApplicationControllerOverrides

  def current_help_topics
    super + [:wingolf]
  end

  def current_layout
    if current_navable && (current_navable.has_flag?(:intranet_root) || (current_navable.ancestor_pages.flagged(:intranet_root).count > 0))
      "wingolf"
    else
      super
    end
  end

end

class ApplicationController
  prepend ApplicationControllerOverrides

  # before_action :new_relic_params
  before_action :collect_data_for_exception_notifier

  before_action :prepend_wingolf_layout_view_path

  def permitted_layouts
    super + ['wingolf', 'wingolf-2017', 'greifenstein']
  end

  protected

  def default_layout
    if Rails.env.test?
      'bootstrap'
    else
      'wingolf'
    end
  end

  # def new_relic_params
  #   ::NewRelic::Agent.add_custom_attributes({
  #     path: request.path,
  #     user_id: (current_user ? current_user.id : nil),
  #     role_view: current_role_view
  #   })
  # end

  def collect_data_for_exception_notifier
    request.env["exception_notifier.exception_data"] = {
      :current_user => current_user
    }
  end

  # Each layout may define override views.
  # When using the layout `foo`, the view
  #
  #     app/views/foo/pages/show.html.haml
  #
  # takes precedence over the usual:
  #
  #     app/views/pages/show.html.haml
  #
  def prepend_wingolf_layout_view_path
    prepend_view_path Rails.application.root.join("app/views/#{current_layout}").to_s
  end

  def resource_centred_layouts
    super + %w(wingolf-2017)
  end

  def set_current_navable(navable)
    super(navable)
    prepend_wingolf_layout_view_path
  end

end