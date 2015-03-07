FactoryGirl.define do

  factory :wingolf_corporation, :class => "Corporation" do
  
    sequence( :token ) { |n| ( "A".."Z" ).to_a[ n ] }
    sequence( :name ) { |n| "#{token.to_s}er Wingolf" }
    sequence( :extensive_name ) { |n| "#{token.to_s}er Wingolf" }
    sequence( :internal_token ) { |n| "#{token.to_s}W" }

    after( :create ) do |corporation|
      corporation.import_default_group_structure "default_group_sub_structures/wingolf_am_hochschulort_children.yml"
      corporation.reload
      
      aktivitas = corporation.child_groups.where(name: 'Aktivitas').first
      aktivitas.update_attribute(:type, 'Aktivitas')
      aktivitas.add_flag :full_members
      Group.alle_aktiven << aktivitas
      
      philisterschaft = corporation.child_groups.where(name: 'Philisterschaft').first
      philisterschaft.update_attribute(:type, 'Philisterschaft')
      philisterschaft.add_flag :full_members
      Group.alle_philister << philisterschaft
    end
  end
end

