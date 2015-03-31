Wingolfsplattform::Application.routes.draw do 

  get 'aktivitates/:id(.:format)', to: 'groups#show', as: 'aktivitas'
  get 'philisterschaften/:id(.:format)', to: 'groups#show', as: 'philisterschaft'
  get 'bvs/:id(.:format)', to: 'groups#show', as: 'bv'

  get "map/show"
  
  # http://railscasts.com/episodes/53-handling-exceptions-revised
  get '(errors)/:status', to: 'errors#show', constraints: {status: /\d{3}/} # via: :all
  
  # See how all your routes lay out with "rake routes"

end

