class Mitgliederdaten::UsersController < ApplicationController
  def index

    # CanCan
    
    # hier werden die Daten aus der Datenbank geholt, in Instanzvariablen gespeichert.
    # @users = .... # Array<Hash>
    @users = []

    for user in User.all
      @user = {}
      @user << { first_name: user.first_name }
      @user << { last_name: user.last_name }
      # @user.merge! { ... }
      for corporation in user.corporations
        header = corporation_token + "_aktivmeldungsdatum"
        # @user << { header.to_sym => UserGroupMembership.find( user: user, group: corporation).created_at.to_datetime .....
      end
      @users << @user
    end
    
    respond_to do |format|
      format.csv { send_data @users.to_csv }
    end
      
  end
end
