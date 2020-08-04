class AktivmeldungenController < ApplicationController

  expose :group
  expose :user, -> { User.new }

  expose :corporations, -> {
    current_user.corporations
    .select { |corporation| can? :update, corporation }
    .collect { |corporation| corporation.as_json.merge({
      postal_address: corporation.postal_address,
      rooms: corporation.rooms.as_json,
      statuses: corporation.status_groups.collect { |g| g.name } - ["Keilgäste", "Aktivenfreundinnen", "Philistergattinen", "Ehrenhaft Ausgetretene", "Schlicht Ausgetretene", "Rausgeworfene (Exclusio)", "Rausgeworfene (Dimissio)", "Gestrichene", "Hausbewohner", "Verstorbene"]
    }) }
  }

  def new
    authorize! :create, User

    user.add_to_corporation = group.id if group.kind_of? Corporation

    set_current_title "Aktivmeldung eintragen"
  end

  expose :corporation, -> { Corporation.find params[:corporation_id] if params[:corporation_id].present? }
  expose :status_group, -> { corporation.descendant_groups.find_by(name: params[:status]) if params[:status].present? }
  expose :existing_user, -> { User.find params[:existing_user_id] if params[:existing_user_id].present? }
  expose :room, -> { Groups::Room.find params[:room_id] if params[:room_id].present? }
  expose :valid_from, -> { params[:valid_from].to_date }

  def create
    authorize! :create, User
    authorize! :update, corporation
    raise 'no corporation given' unless corporation

    new_membership = create_from_aktivmeldung if params[:new_member_type] == 'Aktivmeldung'
    new_membership = create_from_existing_user if params[:new_member_type] == 'Bandaufnahme'
    new_membership = create_from_hausbewohner if params[:new_member_type] == 'Hausbewohner'
    new_membership = create_from_keilgast if params[:new_member_type] == 'Keilgast'
    new_membership = create_from_dame if params[:new_member_type] == 'Dame'

    new_membership.user.delete_cache

    render json: new_membership.as_json(methods: [:user]), status: :ok
  end

  private

  def create_from_aktivmeldung
    raise 'Kein Auftrag zur Datenverarbeitung erteilt.' unless params[:privacy].present?
    new_user = User.create first_name: params[:first_name], last_name: params[:last_name]
    new_user.date_of_birth = params[:date_of_birth].to_date
    new_user.mobile = params[:phone]
    new_user.email = params[:email]
    new_user.study_address = params[:study_address]
    new_user.home_address = params[:home_address]
    new_user.profile_fields.create(
      type: "ProfileFields::Study", label: params[:study],
      from: params[:study_from], university: params[:university], subject: params[:subject]
    )
    new_user.profile_fields.create(
      type: "ProfileFields::BankAccount", label: "Konto",
      account_holder: params[:account_holder], iban: params[:account_iban], bic: params[:account_bic]
    )
    new_user.save

    new_user.leibbursch = User.find params[:leibbursch_id] if params[:leibbursch_id].present?
    new_user.wingolfsblaetter_abo = true
    new_user.generate_alias!
    new_user.save

    new_user.delete_cache
    new_user.fill_in_template_profile_information
    new_user.save

    new_user.create_account
    new_user.send_welcome_email

    status_group.assign_user new_user, at: valid_from
  end

  def create_from_existing_user
    status_group.assign_user existing_user, at: valid_from
  end

  def create_from_hausbewohner
    raise 'Kein Auftrag zur Datenverarbeitung erteilt.' unless params[:privacy].present?
    raise 'Kein Zimmer erkannt.' unless room
    new_user = User.create first_name: params[:first_name], last_name: params[:last_name]
    new_user.date_of_birth = params[:date_of_birth].to_date
    new_user.mobile = params[:phone]
    new_user.email = params[:email] if params[:email].present?
    new_user.study_address = params[:study_address]
    new_user.home_address = params[:home_address]
    new_user.profile_fields.create(
      type: "ProfileFields::Study", label: params[:study],
      from: params[:study_from], university: params[:university], subject: params[:subject]
    )
    new_user.profile_fields.create(
      type: "ProfileFields::BankAccount", label: "Konto",
      account_holder: params[:account_holder], iban: params[:account_iban], bic: params[:account_bic]
    )
    new_user.save

    room.memberships.each { |current_occupancy| current_occupancy.invalidate at: valid_from }
    room.assign_user new_user, at: valid_from
  end

  def create_from_keilgast
    raise 'Kein Auftrag zur Datenverarbeitung erteilt.' unless params[:privacy].present?
    keilgast_group = corporation.sub_group("Keilgäste") || raise("Für die Verbindung #{corporation.name} ist keine Gruppe 'Keilgäste' vorhanden.")

    new_user = User.create first_name: params[:first_name], last_name: params[:last_name]
    new_user.date_of_birth = params[:date_of_birth].to_date if params[:date_of_birth].present?
    new_user.mobile = params[:phone] if params[:phone].present?
    new_user.email = params[:email] if params[:email].present?
    new_user.study_address = params[:study_address] if params[:study_address].present?
    if params[:subject].present?
      new_user.profile_fields.create(
        type: "ProfileFields::Study", label: params[:study],
        from: params[:study_from], university: params[:university], subject: params[:subject]
      )
    end
    if params[:account_iban].present?
      new_user.profile_fields.create(
        type: "ProfileFields::BankAccount", label: "Konto",
        account_holder: params[:account_holder], iban: params[:account_iban], bic: params[:account_bic]
      )
    end
    new_user.save

    keilgast_group.assign_user new_user, at: valid_from
  end

  def create_from_dame
    raise 'Kein Auftrag zur Datenverarbeitung erteilt.' unless params[:privacy].present?

    if params[:dame_type] == "Philister-Gattin"
      damen_group = corporation.sub_group("Philister-Gattinnen") || raise("Für die Verbindung #{corporation.name} ist keine Gruppe 'Philister-Gattinnen' vorhanden.")
    else
      damen_group = corporation.sub_group("Aktiven-Damen") || raise("Für die Verbindung #{corporation.name} ist keine Gruppe 'Aktiven-Damen' vorhanden.")
    end

    new_user = User.create first_name: params[:first_name], last_name: params[:last_name], female: true
    new_user.date_of_birth = params[:date_of_birth].to_date if params[:date_of_birth].present?
    new_user.mobile = params[:phone] if params[:phone].present?
    new_user.email = params[:email] if params[:email].present?
    if params[:address].present?
      new_user.profile_fields.create(
      type: "ProfileFields::Address", label: "Anschrift", value: params[:address]
      )
    end
    if params[:subject].present?
      new_user.profile_fields.create(
        type: "ProfileFields::Study", label: params[:study],
        from: params[:study_from], university: params[:university], subject: params[:subject]
      )
    end
    if params[:account_iban].present?
      new_user.profile_fields.create(
        type: "ProfileFields::BankAccount", label: "Konto",
        account_holder: params[:account_holder], iban: params[:account_iban], bic: params[:account_bic]
      )
    end
    new_user.save

    damen_group.assign_user new_user, at: valid_from
  end

end