FactoryGirl.define do

  factory :bv, aliases: [:bv_group] do
    sequence( :token ) { |n| "BV#{n}" }
    sequence( :name ) { |n| "#{token}" }
    sequence( :extensive_name ) { |n| "Bezirksverband #{n}" }
    sequence( :internal_token ) { |n| "#{token}" }
  end

end
