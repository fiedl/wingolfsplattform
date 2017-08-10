class CreateAktivmeldungJob < ApplicationJob

  def perform(user_params)
    @user_params = user_params

    user = User.create!(basic_user_params)

    user.date_of_birth = Date.new user_params["date_of_birth(1i)"].to_i, user_params["date_of_birth(2i)"].to_i, user_params["date_of_birth(3i)"].to_i

    if user_params["aktivmeldungsdatum(1i)"].present? and user.corporations.count > 0
      user.aktivmeldungsdatum = Date.new user_params["aktivmeldungsdatum(1i)"].to_i, user_params["aktivmeldungsdatum(2i)"].to_i, user_params["aktivmeldungsdatum(3i)"].to_i
    end

    user.phone = user_params["phone"]
    user.mobile = user_params["mobile"]
    user.save

    user.study_address_field.save
    user.home_address_field.save
    user.study_fields.create

    user.address_fields.reload.first.update_attributes user_params["study_address_field"]
    user.address_fields.second.update_attributes user_params["home_address_field"]
    user.study_fields.first.update_attributes user_params["primary_study_field"]

    user.fill_in_template_profile_information
    user.fill_cache

    user.send_welcome_email if user.account
  end


  private

  def basic_user_params
    @user_params.select do |key, value|
      key.in? ['first_name', 'last_name', 'email', 'add_to_corporation', 'create_account']
    end
  end

end