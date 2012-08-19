module GroupsHelper

  def groups_of_user_ul( user )
    content_tag :ul do
      groups_of_user_lis( user )
    end
  end

  def groups_of_user_lis( user )
    
    # TODO:
    # https://trello.com/c/xmFQtRdw
    # 
    # Meine Gruppen
    #   Erlanger Wingolf
    #     Aktivitas
    #       Burschen
    #       Aktive Burschen
    #   Hallenser Wingolf
    #     Aktivitas
    #        Burschen
    #        Inaktive Burschen
    #        Inaktive Burschen non loci
    #   AK Internet

      user.memberships.collect do |membership|
        content_tag :li do
        
          c = link_to membership.group.title, membership.group
          
          if membership.direct?
            c << remove_button( { controller: 'user_group_memberships', 
                                  action: 'destroy', 
                                  user_id: membership.user.id, 
                                  group_id: membership.group.id } )
          end

          c
        end
      end.join.html_safe
  end

  def my_groups_lis
    groups_of_user_lis current_user if current_user
  end
  
#  def groups_of_user_ul( user )
#    Group
#    groups = Groups.of_user user
#    content_tag :ul do
#      (groups.collect do |group|
#        group_li group
#      end).join.html_safe
#    end
#  end
#
#  def group_list_item( group )
#    content_tag :li do
#      link_to group.name, controller: 'groups', action: 'show', id: group.id
#    end
#  end
#
#  def group_li( group )
#    group_list_item group
#  end
end
