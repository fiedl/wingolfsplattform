FactoryGirl.define do

  factory :wah_group, :class => "Corporation" do
    
    sequence( :token ) { |n| ( "A".."Z" ).to_a[ n ] }
    sequence( :name ) { |n| "#{token}er Wingolf" }
    sequence( :extensive_name ) { |n| "#{token}er Wingolf" }
    sequence( :internal_token ) { |n| "#{token}W" }

    after( :create ) do |corporation|
      Group.create_everyone_group unless Group.find_everyone_group
      Group.create_corporations_parent_group unless Group.find_corporations_parent_group
      Group.corporations << corporation
      corporation.import_default_group_structure "default_group_sub_structures/wingolf_am_hochschulort_children.yml"
      
      # Since the structure is read into the database, we have to reload the corporation
      # object somehow to reset the cached associations.
      # 
      # After the update from Rails 3.2 to Rails 4.1, we have to do it like follows,
      # because these are not working anymore:
      #   * corporation.reload   # => causes "stack level too deep"
      #   * corporation = corporation.find(corporation.id)   # => does not return the object
      #
      # TODO: Find out why `corporation.reload` does not work.
      #
      corporation = Corporation.find(corporation.id).first
    end

  end

end
