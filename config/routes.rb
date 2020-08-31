Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  resources :groups, path: :aktivitates, as: :aktivitates
  resources :groups, path: :philisterschaften, as: :philisterschaften
  resources :groups, path: :bvs, as: :bvs

  namespace :groups, path: "" do
    resources :phvs_parents, controller: 'groups_of_groups'
    resources :bvs_parent, controller: 'groups_of_groups'
  end

  namespace :groups do
    resources :wohnheimsvereine
  end

  resources :aktivmeldungen

  resources :users do
    get :wingolf, to: 'user_wingolf_information#index', as: 'wingolf_information'
  end

  get :admins, to: 'admins#index'

  get :wingolfsblaetter, to: 'wingolfsblaetter#index'
  get :wbl, to: 'wingolfsblaetter#index'
  resource :wbl_abo_address_caches

  get 'issues/wingolfsblaetter', to: 'issues#index', scope: 'wingolfsblaetter', as: 'wingolfsblaetter_issues'

  resources :bv_mappings

  namespace :charts do
    namespace :term_reports do
      get :alle_wingolfiten, to: 'alle_wingolfiten#index'
      get 'alle_wingolfiten/anzahl_per_semester', to: 'alle_wingolfiten#anzahl_per_semester'
      get 'alle_wingolfiten/zuwaechse_und_abgaenge_per_semester', to: 'alle_wingolfiten#zuwaechse_und_abgaenge_per_semester'
      get 'aktive_und_philister/anzahl_per_jahr', to: 'aktive_und_philister#anzahl_per_jahr'
    end
  end

  namespace :groups do
    resources :free_groups
  end

  namespace :api do
    namespace :v1 do
      resources :users do
        get :leibfamilie, to: 'users/leibfamilie#show'
        put :leibfamilie, to: 'users/leibfamilie#update'
        post 'leibfamilie/leibfuxen', to: 'users/leibfamilie/leibfuxen#create'
      end
    end
  end

  get "map/show"

  # http://railscasts.com/episodes/53-handling-exceptions-revised
  get '(errors)/:status', to: 'errors#show', constraints: {status: /\d{3}/} # via: :all
end
