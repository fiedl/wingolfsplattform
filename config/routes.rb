Wingolfsplattform::Application.routes.draw do 

  get 'aktivitates/:id(.:format)', to: 'groups#show', as: 'aktivitas'
  get 'philisterschaften/:id(.:format)', to: 'groups#show', as: 'philisterschaft'
  get 'bvs/:id(.:format)', to: 'groups#show', as: 'bv'

  
  # mount Mercury::Engine => '/'

  get "map/show"

  # get "angular_test", controller: "angular_test", action: "index"

  # resources :posts

  match "users/new/:alias" => "users#new"

  match 'profile/:alias' => 'users#show', :as => :profile
  
  # http://railscasts.com/episodes/53-handling-exceptions-revised
  match '(errors)/:status', to: 'errors#show', constraints: {status: /\d{3}/} # via: :all
  
  # See how all your routes lay out with "rake routes"

end

