require 'spec_helper'

describe ProfileField do

  subject { ProfileField.new }

  describe "accessible attributes" do
    [ :label, :type, :value ].each do |attr|
      it { should respond_to( attr ) }
      it { should respond_to( "#{attr}=".to_sym ) }
    end
  end

  it { should respond_to( :profileable ) }

  describe "acts_as_tree" do
    it { should respond_to( :parent ) }
    it { should respond_to( :children ) }
  end

  it { should respond_to( :display_html ) }

end

describe BankAccount do

  before do
    @bank_account = BankAccount.create( label: "Bank Account" )
  end
  subject { @bank_account }

  describe ".create" do
    subject { BankAccount.create( label: "Bank Account" ) }

    it "should create 6 children" do
      subject.children.count.should == 6
    end
    it "should create the correct labels for the children" do
      subject.children.collect { |child| child.label }.should ==
        [ "Account Holder", "Account Number", "Bank Code", 
          "Credit Institution", "IBAN", "BIC" ]
    end

  end

  describe "#account_holder" do
    before do
      @account_holder = "John Doe"
      @bank_account.account_holder = @account_holder
    end
    subject { @bank_account.account_holder }
    it { should == @account_holder }
  end

  describe "#account_holder=" do
    before do
      @new_account_holder = "Johnny Doe"
    end
    it "should set the account holder" do
      @bank_account.account_holder = @new_account_holder
      @bank_account.account_holder.should == @new_account_holder
    end
  end

  describe "other child profile field accessors" do
    before { @profile_field = @bank_account }
    [ :account_holder, :account_number, :bank_code,
      :credit_institution, :iban, :bic ].each do |attr|
      describe "getter method" do
        before do
          @value = "This is a value"
          @profile_field.send( "#{attr}=".to_sym, @value )
        end
        subject { @profile_field.send( attr ) }
        it { should == @value }
      end
      describe "setter method" do
        before { @new_value = "New Value" }
        it "should set the value" do
          @profile_field.send( "#{attr}=".to_sym, @new_value )
          @profile_field.send( attr ).should == @new_value
        end
      end
    end
  end
  
end
