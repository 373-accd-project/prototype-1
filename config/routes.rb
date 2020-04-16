Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get 'login', to: 'sessions#new', as: :login
  post 'login', to: 'sessions#create'
  get 'logout', to: "sessions#destroy", as: :logout
  
  resources :users

  get 'settings', to: 'users#settings', as: :settings

  get 'home', to: 'home#index', as: :home

  root 'home#index'
  post "download_csv", to: "home#download_csv"

  #  QCEW Routes
  get 'qcew', to: "qcew#index"
  post 'qcew', to: "qcew#index"
  post "download_qcew_csv", to: "qcew#download_csv"

  # Local Employment Hours Earnings
  get 'localehe', to: "localehe#index"
  post 'localehe', to: "localehe#index"

  # National Employment Hours and Earnings
  get 'nationalehe', to: "nationalehe#index"
  post 'nationalehe', to: "nationalehe#index"

  #  OES Routes
  get 'oes', to: "oes#index"
  post "oes", to: "oes#index"
  post "download_oes_csv", to: "home#download_csv"

  # LA Unemployment Routes
  get 'launemp', to: 'launemp#index'
  post 'launemp', to: 'launemp#index'
  post "download_launemp_csv", to: "home#download_csv"

end
