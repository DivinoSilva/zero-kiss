Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  get "/healthz", to: "health#ping"

  namespace :api do
    namespace :v1 do
      resources :frames, only: %i[create show destroy]
    end
  end
end
