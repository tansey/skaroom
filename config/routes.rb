SkaMusic::Application.routes.draw do
  root 'welcome#index'

  post "queue/upload"
  
  devise_for :rudies, :controllers => {registrations: 'registrations'}
end
