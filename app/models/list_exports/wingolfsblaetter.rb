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
        :postal_address_country,
        :postal_address,
        :postal_address_postal_code_and_town
      ]
    end

    def data_rows
      super.select do |user|
        user.wingolfit? &&
        user.alive? &&
        user.postal_address_field_or_first_address_field &&
        user.postal_address_field_or_first_address_field.issues.none?
      end.uniq
    end

  end
end