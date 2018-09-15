concern :CurrentEarlyAccessRestrictions do
  included do
    before_action :check_early_access_restrictions
  end

  def check_early_access_restrictions
    if paid_period_expired? && access_to_this_action_restricted?
      if current_user && true # (not current_user.early_access?)
        enforce_early_access_restriction
      end
    end
  end

  def enforce_early_access_restriction
    set_current_navable Page.intranet_root
    set_current_title "Kein Zugriff"
    render "shared/_early_access_restriction"
    return false
  end

  def paid_period_expired?
    paid_until && (paid_until < Time.zone.now)
  end

  def paid_until
    # "2018-06-25".to_datetime
  end

  def access_to_this_action_restricted?
    if kind_of?(PagesController) && (action_name == "show")
      page = Page.find(params[:id])
      if page.public?
        false
      elsif page == project_info_page
        false
      else
        true
      end
    else
      true
    end
  end

  def project_info_page
    Page.find_by(type: "Pages::Plattformprojekt")
  end

end