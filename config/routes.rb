ActionController::Routing::Routes.draw do |map|

  resources :invoices do
    resources :comments
    collection do
      get :search
      post :auto_complete
      get :options
      get :laterun
      post :redraw
      post :redraw_late
    end
  end

end
