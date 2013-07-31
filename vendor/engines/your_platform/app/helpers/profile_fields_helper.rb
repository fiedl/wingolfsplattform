module ProfileFieldsHelper
  def profile_field_label(profile_field)
    if can? :update, profile_field
      best_in_place(profile_field, :label, classes: 'label')
    else
      profile_field.label
    end
  end

  def profile_field_value(profile_field)
    if can? :update, profile_field
      best_in_place(profile_field, :value, classes: 'value')
    else
      profile_field.display_html
    end
  end
end
