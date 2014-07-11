LtiToolProviderRailsExample::Application.routes.draw do
  
  root 'lti_courses#home'
  
  devise_for :users
  
  #== Routes used for LTI Course activities
  post '/course' => "lti_courses#home" # Route for activity 1
  post '/course/check_nonce' => "lti_courses#check_nonce" # Route for activity 2, section 1
  post '/course/check_timestamp' => "lti_courses#check_timestamp" # Route for activity 2, section 2
  post '/course/check_signature' => "lti_courses#check_signature" # Route for activity 2, sections 3 & 4
  post '/course/redirect_users'  => "lti_courses#redirect_users"  # Route for activity 3, sections 1 to 5
  
  # Route for activity 4, sections 1 to 8
  get '/course/config_xml' => "lti_courses#config_xml", :defaults => { :format => 'xml' }
  
  # Routes for activity 5
  post '/course/return_types' => "lti_courses#return_types"
  post '/course/send_link_back' => "lti_courses#send_link_back"
  
  # Routes for activity 6
  post '/course/send_grade' => "lti_courses#send_grade"
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
