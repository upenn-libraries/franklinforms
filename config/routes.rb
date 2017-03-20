Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'forms/:id' => 'form#view'
  post 'forms/:id' => 'form#submit'

  #get '*path' => redirect('/')
end
