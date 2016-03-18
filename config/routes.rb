Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  
  resources :groups, path: :aktivitates, as: :aktivitates
  resources :groups, path: :philisterschaften, as: :philisterschaften
  resources :groups, path: :bvs, as: :bvs
  
  resources :users do
    get :wingolf, to: 'user_wingolf_information#index', as: 'wingolf_information'
  end

  get :admins, to: 'admins#index'
  
  get :wingolfsblaetter, to: 'wingolfsblaetter#index'
  get :wbl, to: 'wingolfsblaetter#index'

  get "map/show"
  
  # http://railscasts.com/episodes/53-handling-exceptions-revised
  get '(errors)/:status', to: 'errors#show', constraints: {status: /\d{3}/} # via: :all
end
