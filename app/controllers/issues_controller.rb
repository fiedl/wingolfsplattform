require_dependency YourPlatform::Engine.root.join('app/controllers/issues_controller').to_s

module IssuesControllerOverrides

  def index
    super

    if params[:scope] == 'wingolfsblaetter'
      set_current_title "Probleme für den Versand der Wingolfsblätter"
      set_current_breadcrumbs [
        {title: t(:administrative_issues), path: issues_path},
        {title: current_title}
      ]
    end
  end

  private

  def load_issues
    super
    @issues = @issues.wingolfsblaetter if params[:scope] == 'wingolfsblaetter'
  end

end

class IssuesController
  prepend IssuesControllerOverrides
end