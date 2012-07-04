Rails.application.routes.draw do
  scope (!Setting.table_exists? || Setting.base_url.blank?) ? "/" : Setting.base_url do
    resources :invoices do
      collection do
        get   :search
        get   :filter
        post  :auto_complete
        get   :options
        post  :redraw
        get   :laterun
        post  :redraw
        post  :redraw_late
      end
      resources :comments
    end
  end
end
