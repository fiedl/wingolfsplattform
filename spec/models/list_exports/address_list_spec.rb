require 'spec_helper'

describe ListExports::AddressList do
  before do
    @group = create :group, name: "Gruppe"
    @corporation = create :corporation_with_status_groups
    @bv = create :bv_group, name: 'BV 01', token: 'BV 01'
    @user = create :user

    @group.assign_user @user
    @corporation.status_groups.first.assign_user @user  # in order to give the @user a #title other than his #name.
    @bv.assign_user @user

    @user_title_without_name = @user.title.gsub(@user.name, '').strip

    @address1 = @user.profile_fields.create(type: 'ProfileFields::Address', value: "Pariser Platz 1\n 10117 Berlin")
    @address1.update_column(:updated_at, "2014-06-20".to_datetime)
    @name_surrounding = @user.profile_fields.create(type: 'ProfileFields::NameSurrounding').becomes(ProfileFields::NameSurrounding)
    @name_surrounding.name_prefix = "Dr."
    @name_surrounding.name_suffix = "M.Sc."
    @name_surrounding.text_above_name = "Herrn"
    @name_surrounding.text_below_name = ""
    @name_surrounding.save
    @user.save

    @list_export = ListExports::AddressList.from_group(@group)
  end

  describe "#headers" do
    subject { @list_export.headers }
    it { should include "BV"}
  end

  describe "#to_csv" do
    subject { @list_export.to_csv }
    it { should include "BV 01"}
  end
end