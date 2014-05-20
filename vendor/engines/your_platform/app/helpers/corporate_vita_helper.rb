module CorporateVitaHelper
  def status_group_membership_valid_from_best_in_place( membership )
    best_in_place( membership,
                   :valid_from_localized_date,  # type: :date,
                   path: user_group_membership_path( id: membership.id,
                                                     controller: :user_group_memberships,
                                                     action: :update,
                                                     format: :json
                                                     ),
                   :classes => "status_group_date_of_joining"
                   )
  end
  
  def status_group_membership_promoted_on_event( membership )
    event = membership.event
    best_in_place( membership,
                   :event_by_name,
                   path: status_group_membership_path( membership ),
                   classes: 'status_event_by_name',
                   # display_with does more harm than it's good for. We wait for angular!
#                   display_with: lambda do |v|
#                     link_to membership.event.name, membership.event, :class => 'status_event_label'
#                   end
                   )
  end


end
