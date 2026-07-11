require 'spec_helper'

describe Birthday do

  describe ".upcoming" do
    before do
      Timecop.travel Time.zone.local(2026, 6, 1)

      @user_june = create :user
      @user_june.date_of_birth = "1990-06-10".to_date
      @user_june.save

      @user_july = create :user
      @user_july.date_of_birth = "1985-07-20".to_date
      @user_july.save

      @user_february = create :user
      @user_february.date_of_birth = "2000-02-01".to_date
      @user_february.save

      @user_without_birthday = create :user
    end

    it "lists the users ordered by their next birthday" do
      Birthday.upcoming.collect(&:user).should == [@user_june, @user_july, @user_february]
    end

    it "wraps around the turn of the year" do
      # In December, the February birthday comes first.
      Timecop.travel Time.zone.local(2026, 12, 1)
      Birthday.upcoming.collect(&:user).first.should == @user_february
    end

    it "does not list users without a date of birth" do
      Birthday.upcoming.collect(&:user).should_not include @user_without_birthday
    end

    it "provides the next birthday date and the new age" do
      birthday = Birthday.upcoming.first
      birthday.date.to_date.should == "2026-06-10".to_date
      birthday.age.should == 36
    end
  end

end
