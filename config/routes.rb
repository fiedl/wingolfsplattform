Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  get 'aktivitates/:id(.:format)', to: 'groups#show', as: 'aktivitas'
  get 'philisterschaften/:id(.:format)', to: 'groups#show', as: 'philisterschaft'
  get 'bvs/:id(.:format)', to: 'groups#show', as: 'bv'
  
  get :admins, to: 'admins#index'

  get "map/show"
  
  # http://railscasts.com/episodes/53-handling-exceptions-revised
  get '(errors)/:status', to: 'errors#show', constraints: {status: /\d{3}/} # via: :all
end
