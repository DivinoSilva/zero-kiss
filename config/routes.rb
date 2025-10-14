Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  get "/healthz", to: "health#ping"

  namespace :api do
    namespace :v1 do
      resources :frames, only: %i[create show destroy] do
        resources :circles, only: %i[create]
      end
      resources :circles, only: %i[index update destroy]
    end
  end
end
