require 'rails_helper'

RSpec.describe FormController, type: :routing do
  it 'routes /forms/ill to form#ill' do
    expect(get '/forms/ill').to route_to 'form#ill'
  end
  it 'routes /forms/missing to form#view' do
    expect(get '/forms/missing').to route_to 'form#view', id: 'missing'
  end
end