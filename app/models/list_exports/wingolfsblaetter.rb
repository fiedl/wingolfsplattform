module ListExports
  class Wingolfsblaetter < Base
    
    def columns
      [
        :last_name,
        :first_name,
        :male_or_female_salutation,
        :personal_title,
        :postal_address_street_with_number,
        :postal_address_second_address_line,
        :postal_address_postal_code,
        :postal_address_town,
        :postal_address_country
      ]
    end
    
    def data_rows
      super.select do |user|
        user.wingolfit? and user.alive?
      end.uniq
    end
    
  end
end