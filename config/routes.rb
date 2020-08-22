Rails.application.routes.draw do

  get 'welcome/index' # default Rails welcome page

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope "/#{ENV['RAILS_RELATIVE_URL_ROOT']}" do
    root to: 'authors#index'

    resources :authors
    resources :chapters

    # Authentication
    get "signup" => "users#new",        as: :signup
    post "users" => "users#create",     as: :create_user

    get "login"  => "sessions#new",     as: :login
    post "login" => "sessions#create",  as: :create_login
    get "logout" => "sessions#destroy", as: :logout

    # AJAX end points
    get  "authors/letters"                => "authors#author_letters"
    get  "authors/letters/:letter"        => "authors#authors"

    post "authors/import/:author_id"      => "authors#import_author"
    get "authors/check/:author_id"        => "authors#check"

    get  "items/author/:author_id"   => "items#get_by_author", as: :item_by_author

    post "items/import/:type/:id"    => "items#import",        as: :item_import
    post "items/mark/:type/:id"      => "items#mark",          as: :item_mark
    post "items/check/:type/:id"     => "items#check",         as: :item_check
    post "items/dni/:type/:id"       => "items#dni",           as: :item_dni
    get  "items/audit/:type/:id"     => "items#audit",         as: :item_audit

    # Admin features
    resource :archive_configs, path: :config
    resources :archive_configs, path: :config, only: [:edit, :show, :update]

    get "stats/api", to: "stats#stats"
    get "stats", to: "authors#index"

    mount ActionCable.server => '/cable'
  end
end
