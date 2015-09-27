require_dependency YourPlatform::Engine.root.join('app/controllers/posts_controller').to_s

module PostsControllerOverride
  
  def create
    raise "Aufgrund aktueller Missbrauchfälle blockiert."
  end

  private
  
  def create_via_email
    raise "blocked due to current abuse issue."
  end
  
end  

class PostsController
  prepend PostsControllerOverride
end