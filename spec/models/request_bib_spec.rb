require 'rails_helper'

RSpec.describe RequestBib, type: :model do
  context 'data fields' do
    it 'returns the value from params for bib data fields, preferring keys in order given' do
      params = {
        'title' => 'Test Title', 'Book' => 'Test Book', 'booktitle' => 'Test Booktitle',
        'article' => 'Test Article', 'atitle' => 'Test Atitle'
      }
      bib = RequestBib.new params
      expect(bib.booktitle).to eq 'Test Title'
      expect(bib.article).to eq 'Test Article'
    end
    it 'returns the default if no value found using given keys' do
      bib = RequestBib.new({})
      expect(bib.source).to eq 'direct'
    end
  end
end