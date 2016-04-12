module ListExports
  
  # Stammdaten auf der Basis des Vorschlages von Sebastian Deißner.
  # Vorgang: 2015-Bai3Aes0, Beschluss vom 20.02.2016.
  # Trello: https://trello.com/c/Rsoo0cFQ/968-deissner-liste-2015-bai3aes0
  #
  class Stammdaten < Base
    
    def columns
      [
        :last_name,
        :first_name,
        :aktivitaetszahl,
        :personal_title,
        :academic_degree,
        :w_nummer,
        :localized_date_of_birth,
        :postal_address,
        :phone,
        :email,
        :studium_export_string,
        :status_export_string,
        :bv_token,
        :im_bv_seit
      ]
    end
    
  end
  
end