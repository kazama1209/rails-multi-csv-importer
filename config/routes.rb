Rails.application.routes.draw do
  resources :csv, only: %i[index create] do
    collection do
      post :import
    end
  end
end
