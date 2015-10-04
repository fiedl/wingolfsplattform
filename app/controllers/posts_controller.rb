require_dependency YourPlatform::Engine.root.join('app/controllers/posts_controller').to_s

module PostsControllerOverride
  
end  

class PostsController
  prepend PostsControllerOverride
end