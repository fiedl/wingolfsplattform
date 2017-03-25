require 'spec_helper'

describe ListExport do

  before do
    @group = create :group, name: "Gruppe"
    @corporation = create :corporation_with_status_groups
    @bv = create :bv_group, name: 'BV 01', token: 'BV 01'
    @user = create :user

    @group.assign_user @user
    @corporation.status_groups.first.assign_user @user  # in order to give the @user a #title other than his #name.
    @bv.assign_user @user

    @user_title_without_name = @user.title.gsub(@user.name, '').strip
  end

  describe "name_list: " do
    before do
      @user.profile_fields.create(type: 'ProfileFields::AcademicDegree', value: "Dr. rer. nat.", label: :academic_degree)
      @user.profile_fields.create(type: 'ProfileFields::General', value: "Dr.", label: :personal_title)

      @list_export = ListExports::NameList.from_group(@group)
    end
    describe "#headers" do
      subject { @list_export.headers }
      it { should == ['Nachname', 'Vorname', 'Aktivitätszahl', 'Persönlicher Titel', 'Akademischer Grad', "Mitglied in 'Gruppe' seit", 'BV'] }
    end
    describe "#to_csv" do
      subject { @list_export.to_csv }
      it { should == "Nachname;Vorname;Aktivitätszahl;Persönlicher Titel;Akademischer Grad;Mitglied in 'Gruppe' seit;BV\n" +
        "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};Dr.;Dr. rer. nat.;#{I18n.l Date.today};BV 01\n" }
    end
  end

end