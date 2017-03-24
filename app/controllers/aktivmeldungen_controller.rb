class AktivmeldungenController < ApplicationController

  expose :group
  expose :user, -> { User.new }

  def new
    authorize! :create, User

    user.add_to_corporation = group.id if group.kind_of? Corporation

    set_current_title "Aktivmeldung eintragen"
  end

  def create
    authorize! :create, User

    if not all_required_fields_filled_in?
      user.first_name = user_params[:first_name]
      user.last_name = user_params[:last_name]
      user.email = user_params[:email]

      flash[:error] = 'Informationen zur Aktivmeldung wurden nicht vollständig ausgefüllt. Bitte Eingabe wiederholen.'
      if not current_user.global_admin? and not user_params['add_to_corporation'].present?
        flash[:error] += " Es wurde keine Verbindung angegeben. Die Aktivmeldung konnte nicht eingetragen werden."
      end

      set_current_title "Aktivmeldung eintragen"
      render :action => "new"
    else

      CreateAktivmeldungJob.perform_later(user_params)
      flash[:notice] = "Die Aktivmeldung wurde eingetragen. Es dauert ein paar Minuten, bis der neue Wingolfit auf der Plattform angezeigt wird."
      redirect_to root_path

    end
  end

  private

  def user_params
    params.require(:user).permit(
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
  end

  def required_fields
    [
      'first_name', 'last_name',
      'date_of_birth(1i)', 'date_of_birth(2i)', 'date_of_birth(3i)',
      'study_address_field', 'home_address_field', 'email', 'mobile',
      (current_user.global_admin? ? nil : 'add_to_corporation')
    ] - [nil]
  end

  def all_required_fields_filled_in?
    (user_params.select { |k,v| v.present? }.keys & required_fields).count == required_fields.count
  end

end