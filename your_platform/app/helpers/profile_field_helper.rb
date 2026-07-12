module ProfileFieldHelper

  def profile_field_li( profile_field, options = {} )
    # The server-rendered partial 'profile_fields/profile_field' was
    # removed with the tabler redesign (55e03fb8f); profile fields
    # render as vue components now, which bring their own edit
    # controls. The former options (lock_label, no_remove) are
    # accepted but obsolete.
    content_tag :li, editable_profile_field(profile_field), class: "attribute profile_field" if profile_field
  end

  def profile_field_lis( profile_fields, options = {} )
    profile_fields.collect do |profile_field|
      profile_field_li(profile_field, options)
    end.join.html_safe
  end


  # args:
  #   profileable
  #   profile_field_type
  #   profile_section
  #
  def link_to_add_profile_field( args )
    raise ActionController::ParameterMissing, "expected argument 'profileable'" unless args[:profileable].present?
    raise ActionController::ParameterMissing, "expected argument 'profile_field_type'" unless args[:profile_field_type].present?
    raise ActionController::ParameterMissing, "expected argument 'profile_section'" unless args[:profile_section].present?
    label_in_english_with_underscores = args[:profile_field_type].demodulize.underscore
    link_to( I18n.t(label_in_english_with_underscores),
             profile_fields_path(
               :profileable_id => args[:profileable].id,
               :profileable_type => args[:profileable].class.base_class.name,
               :profile_field => {:type => args[:profile_field_type]},
               :section => args[:profile_section],
               :label => label_in_english_with_underscores
             ),
             :id => "add_#{label_in_english_with_underscores}_field",
             :remote => true,
             :method => 'post',
             class: args[:class]
           )
  end
end
