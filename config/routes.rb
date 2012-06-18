Wingolfsplattform::Application.routes.draw do 

  root :to => 'root#index'

  resources :pages
  resources :groups #do

  match "sessions/logout" => "sessions#logout"
  resources :sessions

  match "users/new/:alias" => "users#new"


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  resources :users do
    get :autocomplete_title, on: :collection
  end

  resources :workflows

  resources :profile_fields
  resources :relationships

  delete 'user_group_memberships/group/:group_id/user/:user_id', controller: :user_group_memberships, action: :destroy

#  resources :user_group_memberships

#  match 'profile/:alias' => 'users#show', :as => :profile
  match ':alias' => 'users#show', :as => :profile

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match 'controllers/:controller(/:action(/:id))(.:format)'

  match 'ajax/:controller(/:action(/:id))(.:format)', ajax: true

end
