Rails.application.routes.draw do

  get 'forms/static/ill_problem', to: 'static#ill_problem', as: :ill_problem

  get 'redir/aeon' => 'form#aeon'
  get 'redir/ares' => 'form#ares'
  get 'redir/help' => 'form#help'

  get 'redir/:id' => 'form#redir'
  post 'redir/:id' => 'form#submit'

  get 'forms/:id' => 'form#view', as: 'form'
  post 'forms/:id' => 'form#submit'

  scope :forms, path: 'forms' do
    get '/request/new', to: 'request#new', as: :new_request

    resource :local_requests, only: %i[new create show] do
      collection do
        get 'test'
      end
    end

    get '/alma/:mms_id/holding/:holding_id/items',
        to: 'holding_items#index', format: :json
  end

  #get '*path' => redirect('/')
end
