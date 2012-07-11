# -*- coding: utf-8 -*-
class UserAccount < ActiveRecord::Base
  has_secure_password 

  belongs_to               :user, inverse_of: :user_account

  # Gibt das Benutzerobjekt zurück, dass zum Login-String und dem angegebenen Passwort passt. 
  # Wenn etwa zwei Benutzer den gleichen Nachnamen haben, dient also das Passwort der Identifizierung.
  # TODO: ACHTUNG: Ist das eine Sicherheitslücke? Wenn nämlich zwei Benutzer gleichen Nachnamens das gleiche Passwort haben, kann 
  # es passieren, dass man als der falsche Benutzer Zugang erhält. 
  def self.authenticate( login_string, password )
    users = UserIdentification.find_users( login_string )
    authenticated_user = nil
    if users
      users.each do |user| 
        if user.has_account?
          if user.account.authenticate password
            authenticated_user = user
          else
            raise 'wrong_password'
          end
        else
          raise 'user_has_no_account'
        end
      end
      if authenticated_user.nil?
        raise 'no_user_found'
      end
    else
      raise 'no_user_found'
    end
    if authenticated_user
      return authenticated_user
    end
  end

  # This generates a new user account for the user this account belongs to. 
  # This causes the system to generate an account, generate a password for it, and send the password
  # to the account owner via email.
  def generate
    self.password = UserPassword.generate
    begin
      UserAccountMailer.welcome_email( self.user, password ).deliver
    rescue
      raise "Could not send welcome email due to unreachable mail server (sender)."
    end
  end

end
