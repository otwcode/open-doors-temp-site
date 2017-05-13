Rails.application.routes.draw do

  get 'welcome/index' # default Rails welcome page

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope "/#{APP_CONFIG[:sitekey]}" do
    root :to => 'authors#index'

    resources :authors do
      post :import
      post :mark
      post :dni
    end

    resources :chapters

    post "items/import/:type/:id" => "items#import", as: :item_import
    post "items/mark/:type/:id" => "items#mark", as: :item_mark
    post "items/dni/:type/:id" => "items#dni", as: :item_dni
  end
end
