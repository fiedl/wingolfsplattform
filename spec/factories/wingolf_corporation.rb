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

      corporation.sub_group("Verstorbene").add_flag :deceased_parent
      corporation.sub_group("Ehemalige").add_flag :former_members_parent

      # Um die Status-Gruppen mit dem Typ `StatusGroup` zu versehen,
      # wird einfach die entsprechende Reparatur-Methode aufgerufen, die auch
      # für production vorgesehen war.
      StatusGroup.repair

      status_workflow = Workflow.create name: 'Reception', description: "Macht aus einem Hospitanten einen Kraßfuxen."

      # # Does not work:
      # status_workflow.steps.create(brick_name: "RemoveFromGroupBrick", parameters: { :group_id => corporation.status_groups.first.id })
      # status_workflow.steps.create(brick_name: "AddToGroupBrick", parameters: { :group_id => corporation.status_groups.second.id })

      step = status_workflow.steps.create
      step.brick_name = 'RemoveFromGroupBrick'
      step.save
      param = step.parameters.create
      param.key = :group_id
      param.value = corporation.status_groups.first.id
      param.save

      step = status_workflow.steps.create
      step.brick_name = 'AddToGroupBrick'
      step.save
      param = step.parameters.create
      param.key = :group_id
      param.value = corporation.status_groups.second.id
      param.save

      status_workflow.parent_groups << corporation.status_groups.first
    end
  end
end

