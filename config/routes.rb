Rails.application.routes.draw do

  get 'forms/static/ill_problem', to: 'static#ill_problem', as: :ill_problem

  get 'redir/aeon' => 'form#aeon'
  get 'redir/ares' => 'form#ares'
  get 'redir/help' => 'form#help'

  get 'redir/:id' => 'form#redir'
  post 'redir/:id' => 'form#submit'

  get 'forms/:id' => 'form#view', as: 'form'
  post 'forms/:id' => 'form#submit'

  resource :local_requests, only: [:new, :create, :show]

  #get '*path' => redirect('/')
end
