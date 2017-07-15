Rails.application.routes.draw do

  get 'welcome/index' # default Rails welcome page

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope "/#{APP_CONFIG[:sitekey]}" do
    root to: 'authors#index'

    resources :authors do
      post :import
      post :mark
      post :check
      post :dni
    end

    resources :chapters

    resources :archive_config, path: :config

    # Authentication
    get "signup" => "users#new",        as: :signup
    post "users" => "users#create",     as: :create_user

    get "login"  => "sessions#new",     as: :login
    post "login" => "sessions#create",  as: :create_login
    get "logout" => "sessions#destroy", as: :logout

    # AJAX end points
    post "items/import/:type/:id" => "items#import",  as: :item_import
    post "items/mark/:type/:id"   => "items#mark",    as: :item_mark
    post "items/check/:type/:id"  => "items#check",   as: :item_check
    post "items/dni/:type/:id"    => "items#dni",     as: :item_dni
    get  "items/audit/:type/:id"  => "items#audit",   as: :item_audit
  end
end
