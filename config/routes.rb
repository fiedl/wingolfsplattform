Wingolfsplattform::Application.routes.draw do 

  get "errors/unauthorized"

  # mount Mercury::Engine => '/'

  get "map/show"

  # get "angular_test", controller: "angular_test", action: "index"

  resources :posts
  resources :events  

  mount WorkflowKit::Engine => "/workflow_kit", as: 'workflow_kit'

  get 'profile/:alias', to: 'users#show', :as => :profile
  
  # http://railscasts.com/episodes/53-handling-exceptions-revised
  get '(errors)/:status', to: 'errors#show', constraints: {status: /\d{3}/} # via: :all
  
  # See how all your routes lay out with "rake routes"

end

