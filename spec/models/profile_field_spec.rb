# -*- coding: utf-8 -*-
require 'spec_helper'

# Profile Fields in General
# ==========================================================================================

describe ProfileField do
end


# Address Information
# ==========================================================================================

describe ProfileFieldTypes::Address do

  before do
    @address_field = ProfileFieldTypes::Address.create( label: "Address of the Brandenburg Gate",
                                                        value: "Pariser Platz 1\n 10117 Berlin" )
    @address_field.convert_to_format_with_separate_fields

    create( :bv_group, name: "BV 00" ) # just to have another one in the database
    @bv = create( :bv_group, name: "BV 01", token: "BV 01" )

    BvMapping.create(bv_name: "BV 01", plz: "10117", town: "Berlin")
  end

  describe "#bv" do
    subject { @address_field.bv }
    it "should return the correct Bv (Bezirksverband)" do
      subject.should == @bv
    end
  end

  describe "#display_html" do
    subject { @address_field.display_html }
    it "should include the BV" do
      subject.should include I18n.translate(:address_is_in_the)
      subject.should include @address_field.bv.name
    end
  end

  specify "changing an address should trigger a bv change of the user" do
    @user = create :user
    @corporation = create :wingolf_corporation
    @corporation.philisterschaft.assign_user @user, at: 1.year.ago
    @address_field = @user.profile_fields.create type: 'ProfileFieldTypes::Address', label: 'Address', value: '44 Rue de Stalingrad, Grenoble, Frankreich'
    @address_field.convert_to_format_with_separate_fields
    @country_code_field = @address_field.find_child_by_key(:country_code)
    @city_field = @address_field.find_child_by_key(:city)
    @postal_code_field = @address_field.find_child_by_key(:postal_code)
    @user.bv.should_not == @bv

    @country_code_field.value = 'DE'; @country_code_field.save
    @postal_code_field.value = '10117'; @postal_code_field.save
    @city_field.value = 'Berlin'; @city_field.save
    @user.reload.bv.should == @bv
  end

end


# Studies Information
# ==========================================================================================

describe ProfileFieldTypes::Study do

  subject { ProfileFieldTypes::Study.create() }

  its( 'children.count' ) { should == 5 }
  it { should respond_to :from }
  it { should respond_to :from= }
  it { should respond_to :to }
  it { should respond_to :to= }
  it { should respond_to :university }
  it { should respond_to :university= }
  it { should respond_to :subject }
  it { should respond_to :subject= }
  it { should respond_to :specialization }
  it { should respond_to :specialization= }

end
