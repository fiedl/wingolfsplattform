concern :GroupSearch do
  include StructureableSearch

  included do
    attr_accessor :search_hint
  end

  class_methods do

    def search(query, limit: 10000, current_user: nil)
      if current_user
        result = search_in_my_groups(query, user: current_user)
        result = search_in_my_corporations(query, user: current_user) unless result.present?
      end
      result = search_by_name(query) unless result.present?
      if current_user
        result = search_in_my_groups(query, user: current_user, include_ancestors: true) unless result.present?
        result = search_in_my_corporations(query, user: current_user, include_ancestors: true) unless result.present?
      end
      result = search_by_name(query, include_ancestors: true) unless result.present?
      result = (search_by_name(query).limit(limit) + search_by_breadcrumbs(query, limit: limit) + search_by_profile_fields(query)) unless result.present?
      self.where(id: result).regular.distinct.limit(limit)
    end

    def search_in_my_groups(query, user:, include_ancestors: false)
      search_by_name(query, include_ancestors: include_ancestors).where(id: user.groups)
    end

    def search_in_my_corporations(query, user:, include_ancestors: false)
      search_by_name(query, include_ancestors: include_ancestors).where(id: user.corporations.map(&:descendant_group_ids).flatten)
    end

    private

    def search_by_name(query, include_ancestors: false)
      if include_ancestors
        search_by_name_with_ancestors(query)
      else
        search_by_name_without_ancestors(query)
      end
    end

    def search_by_name_with_ancestors(query)
      relation = self
      query.split(" ").each do |expression|
        groups_with_matching_name = Group.where("groups.name ILIKE :e OR groups.extensive_name ILIKE :e", e: "%#{expression}%")
        ids_with_matching_ancestor = Dag::Traversal.descendant_ids of_type: 'Group',
          of_ids: groups_with_matching_name.pluck(:id), type: 'Group'
        relation = relation.where("groups.name ILIKE :e OR groups.extensive_name ILIKE :e OR groups.id IN (:ancestor_matches)",
          e: "%#{expression}%", ancestor_matches: ids_with_matching_ancestor + [0])
      end
      relation.distinct
    end

    def search_by_name_without_ancestors(query)
      relation = self
      query.split(" ").each do |expression|
        relation = relation.where("groups.name ILIKE ? OR groups.extensive_name ILIKE ?", "%#{expression}%", "%#{expression}%")
      end
      relation.distinct
    end

    def search_by_extensive_name(query)
      where("extensive_name ILIKE ?", "%#{query}%")
    end

    def search_by_profile_fields(query)
      q = "%" + query.gsub(' ', '%') + "%"
      profile_fields =
        ProfileField.where(profileable_type: "Group").where("value ILIKE ? or label ILIKE ?", q, q) +
        ProfileField.joins(:parent).where(parents_profile_fields: {profileable_type: "Group"}).where("profile_fields.value ILIKE ? or profile_fields.label ILIKE ?", q, q)
      groups = profile_fields.collect do |profile_field|
        group = profile_field.profileable
        group.search_hint = "#{profile_field.label}: #{profile_field.value}"
        group
      end
    end

  end
end