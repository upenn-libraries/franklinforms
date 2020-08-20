Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'forms/ill', to: 'form#ill'

  get 'redir/aeon' => 'form#aeon'
  get 'redir/ares' => 'form#ares'
  get 'redir/help' => 'form#help'

  get 'redir/:id' => 'form#redir'
  post 'redir/:id' => 'form#submit'

  get 'forms/:id' => 'form#view', as: 'form'
  post 'forms/:id' => 'form#submit'

  #get '*path' => redirect('/')
end
