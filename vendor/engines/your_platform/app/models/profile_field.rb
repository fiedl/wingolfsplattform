# -*- coding: utf-8 -*-
class ProfileField < ActiveRecord::Base

  attr_accessible        :label, :type, :value, :key

  belongs_to             :profileable, polymorphic: true
  
  include ProfileFieldMixins::HasChildProfileFields

  # Only allow the type column to be an existing class name.
  #
  validates_each :type do |record, attr, value| 
    if value
      if not ( defined?( value.constantize ) && ( value.constantize.class == Class ) && value.start_with?( "ProfileFieldTypes::" ) )
        record.errors.add "#{value} is not a ProfileFieldTypes class."
      end
    end
  end

  # There are profile_fields that are composed of other profile_fields.
  # For example, the BankAccount profile_field type is composed.
  #
  #   BankAccount
  #        |------- ProfileField:  :label => "Account Holder"
  #        |------- ProfileField:  :label => "Account Number"
  #        |------- ProfileField:  :label => "Bank Code"
  #        |------- ProfileField:  :label => "Credit Institution"
  #        |------- ProfileField:  :label => "IBAN"
  #        |------- ProfileField:  :label => "BIC"
  #
  # You can add this structured ProfileField manually:
  #
  #    account = ProfileField.create( label: "Bank Account", type: "BankAccount" )
  #    account.children.create( label: "Account Holder", value: ... )
  #    ...
  #
  # Or, you can use the customized `create` method of the specialized class BankAccount,
  # which inherits from ProfileField, to create a blank BankAccount-type profile_field
  # with all children auto-created empty.
  #
  #    account = BankAccount.create( label: "Bank Account" )
  #
  acts_as_tree

  # Profile fields may have flags, e.g. :preferred_address.
  #
  has_many_flags

  # Often, profile_fields are to be displayed in a certain manner on a HTML page.
  # This method returns the profile_field's value as HTML code in the way
  # the profile_field should be displayed.
  #
  # Override this in the inheriting classes in ordner to modify the html output
  # of the value.
  #
  def display_html
    self.value
  end

  # This method returns the key, i.e. the un-translated label, 
  # which is needed for child profile fields.
  #
  def key
    read_attribute :label
  end
  
  # This method returns the label text of the profile_field.
  # If a translation exists, the translation is returned instead.
  #
  def label
    label_text = super
    translated_label_text = I18n.translate( label_text, :default => label_text.to_s ) if label_text
  end

  # If the field has children, their values are included in the main field's value.
  # Attention! Probably, you want to display only one in the view: The main value or the child fields.
  # 
  def value
    if children.count > 0
      ( [ super ] + children.collect { |child| child.value } ).join(", ")
    else
      super
    end
  end

  # This creates an easier way to access a composed ProfileField's child field
  # values. Instead of calling
  #
  #    bank_account.children.where( :label => :account_number ).first.value
  #    bank_account.children.where( :label => :account_number ).first.value = "12345"
  #
  # you may call
  #
  #    bank_account.account_number
  #    bank_account.account_number = "12345"
  #
  # after telling the profile_field to create these accessors:
  #
  #    class BankAccount < ProfileField
  #      ...
  #      has_child_profile_fields :account_holder, :account_number, ...
  #      ...
  #    end
  #
  # Furthermore, this method modifies the intializer to build the child fields
  # on build of the main profile_field.
  extend ProfileFieldMixins::HasChildProfileFields

  # In order to namespace the type classes of the profile_fields, we place them
  # in a module. In order to be able to use the type column without including
  # the module, this method makes sure that the module is included in the
  # type column on save.
  #
  # Both versions should work:
  #     ProfileField.create( label: "My Address", value: "...", type: "Address" )
  #     ProfileField.create( label: "My Address", value: "...", type: "ProfileField::Address" )
  #
  # The long version `ProfileField::...` is stored in the database.
  #
  before_save :include_module_in_type_column
  def include_module_in_type_column
    type = "ProfileFieldTypes::#{type}" if not type.include?( "::" ) if type
  end
  private :include_module_in_type_column

end

