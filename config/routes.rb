Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get 'home', to: 'home#index'
  post "home", to: "home#index"
  get 'qcew', to: "qcew#index"
  get 'oes', to: "oes#index"
  post "download_csv", to: "home#download_csv"
end
