require_dependency YourPlatform::Engine.root.join('app/controllers/search_controller').to_s

module SearchControllerOverride
  def find_preview_object(query_string)
    object = Bv.where(token: [query_string, query_string.gsub('BV', 'BV ').gsub('bv', 'BV ')]).limit(1).first
    object ||= super(query_string)
  end
end  

class SearchController
  prepend SearchControllerOverride
end