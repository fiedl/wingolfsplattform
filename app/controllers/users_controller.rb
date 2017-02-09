require_dependency YourPlatform::Engine.root.join('app/controllers/users_controller').to_s

module UsersControllerModifications

  def new
    @title = "Aktivmeldung eintragen" # t(:create_user)
    @user = User.new

    @group = Group.find(params[:group_id]) if params[:group_id]
    @user.add_to_corporation = @group.becomes(Corporation).id if @group && @group.corporation?

    @user.alias = params[:alias]
  end

  def create

    # Diese Parameter werden vom Aktivmeldungs-Formular übergeben.
    #
    @user_params = params.require(:user).permit(
      :first_name, :last_name,
      'date_of_birth(1i)', 'date_of_birth(2i)', 'date_of_birth(3i)',
      :add_to_corporation,
      'aktivmeldungsdatum(1i)', 'aktivmeldungsdatum(2i)', 'aktivmeldungsdatum(3i)',
      :email, :phone, :mobile,
      :create_account,
      study_address_field: [:first_address_line, :second_address_line, :postal_code, :city, :region, :country_code],
      home_address_field: [:first_address_line, :second_address_line, :postal_code, :city, :region, :country_code],
      primary_study_field: [:label, :from, :university, :subject, :specialization]
    )

    # Diese Parameter werden teils sofort verarbeitet, und zwar die `@basic_user_params`,
    # teils dann asynchron in einem Background-Worker.
    #
    @basic_user_params = @user_params.select do |key, value|
      key.in? ['first_name', 'last_name', 'email', 'add_to_corporation', 'create_account']
    end

    # Wir müssen überprüfen, ob alle Pflicht-Felder angegeben wurden. Wenn nicht, wird das Formular
    # nocheinmal angezeigt mit einem entsprechenden Hinweis.
    #
    @required_parameters_keys = ['first_name', 'last_name',
      'date_of_birth(1i)', 'date_of_birth(2i)', 'date_of_birth(3i)',
      'study_address_field', 'home_address_field', 'email', 'mobile' ]

    # Lokale Administratoren müssen eine Verbindung angeben, da sie sonst einen Benutzer anlegen,
    # den sie selbst nicht mehr administrieren können.
    #
    # Wenn kein Aktivmeldungsdatum angegeben ist, wird einfach das aktuelle Datum verwendet.
    #
    if not current_user.global_admin?
      @required_parameters_keys += ['add_to_corporation']
    end

    if (@user_params.select { |k,v| v.present? }.keys & @required_parameters_keys).count != @required_parameters_keys.count

      # Wenn nicht alle erforderlichen Parameter angegeben wurden, muss nocheinmal nachgefragt werden.

      @title = "Aktivmeldung eintragen"
      @user = User.new(@basic_user_params)
      @user.valid?

      flash[:error] = 'Informationen zur Aktivmeldung wurden nicht vollständig ausgefüllt. Bitte Eingabe wiederholen.'
      if not current_user.global_admin? and not @basic_user_params['add_to_corporation'].present?
        flash[:error] += " Es wurde keine Verbindung angegeben. Die Aktivmeldung konnte nicht eingetragen werden."
      end

      render :action => "new"

    else

      # Wenn alle erforderlichen Parameter angegeben wurden, kann die Aktivmeldung eingetragen werden.

      UsersController.delay.create_async(@basic_user_params, @user_params)
      flash[:notice] = "Die Aktivmeldung wurde eingetragen. Es dauert ein paar Minuten, bis der neue Wingolfit auf der Plattform angezeigt wird."
      redirect_to root_path

    end
  end

  private

  def user_params
    additional_permitted_keys = []
    additional_permitted_keys += [:wingolfsblaetter_abo, :localized_bv_beitrittsdatum] if @user && can?(:update, @user)
    super.merge params.require(:user).permit(*additional_permitted_keys)
  end

end

class UsersController
  prepend UsersControllerModifications

  # This method asynchronously creates a new user when called like this:
  #
  #    UsersController.delay.create_async(@basic_user_params, @user_params)
  #
  def self.create_async(basic_user_params, all_user_params)
    user = User.create!(basic_user_params)

    # $enable_tracing = false
    # $trace_out = open('trace.txt', 'w')
    #
    # set_trace_func proc { |event, file, line, id, binding, classname|
    #   if $enable_tracing && event == 'call'
    #     $trace_out.puts "#{Time.zone.now.to_s} #{file}:#{line} #{classname}##{id}"
    #   end
    # }
    #
    # $enable_tracing = true

    user.date_of_birth = Date.new all_user_params["date_of_birth(1i)"].to_i, all_user_params["date_of_birth(2i)"].to_i, all_user_params["date_of_birth(3i)"].to_i

    if all_user_params["aktivmeldungsdatum(1i)"].present? and user.corporations.count > 0
      user.aktivmeldungsdatum = Date.new all_user_params["aktivmeldungsdatum(1i)"].to_i, all_user_params["aktivmeldungsdatum(2i)"].to_i, all_user_params["aktivmeldungsdatum(3i)"].to_i
    end

    user.phone = all_user_params["phone"]
    user.mobile = all_user_params["mobile"]
    user.save

    user.study_address_field.save
    user.home_address_field.save
    user.study_fields.create

    user.address_fields(true).first.update_attributes all_user_params["study_address_field"]
    user.address_fields.second.update_attributes all_user_params["home_address_field"]
    user.study_fields.first.update_attributes all_user_params["primary_study_field"]

    user.send_welcome_email if user.account

    # FIXME: This may raise 'stack level too deep' when run through sidekiq:
    user.fill_in_template_profile_information

    user.delay.fill_cache
    Group.alle_aktiven.delay.fill_cache
  end

end