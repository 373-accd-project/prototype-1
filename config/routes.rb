Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get 'home', to: 'home#index'
  post "home", to: "home#index"

  #  QCEW Routes
  get 'qcew', to: "qcew#index"
  post "download_qcew_csv", to: "qcew#download_csv"
  
  get 'localehe', to: "localehe#index"
  post 'localehe', to: "localehe#index"
  get 'nationalehe', to: "nationalehe#index"
  post 'nationalehe', to: "nationalehe#index"

  #  OES Routes
  get 'oes', to: "oes#index"
  post "oes", to: "oes#index"
  post "download_oes_csv", to: "oes#download_csv"

  # LA Unemployment Routes
  get 'launemp', to: 'launemp#index'
  post 'launemp', to: 'launemp#index'
  post "download_launemp_csv", to: "launemp#download_csv"

end
