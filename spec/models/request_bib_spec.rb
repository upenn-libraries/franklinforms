require 'rails_helper'

RSpec.describe RequestBib, type: :model do
  context '#value_at' do
    it 'returns the value from params, preferring keys in order' do
      params = {
        'title': 'Test Title', 'Book': 'Test Book', 'booktitle': 'Test Booktitle',
        'article': 'Test Article', 'atitle': 'Test Atitle'
      }
      bib = RequestBib.new params
      title_value = bib.value_at %w[title Book bookTitle booktitle rft.title]
      article_value = bib.value_at %w[Article article atitle rft.atitle]
      expect(title_value).to eq 'Test Title'
      expect(article_value).to eq 'Test Article'
    end
    it 'returns the default if no value found using keys' do
      bib = RequestBib.new({})
      expect(
        bib.value_at([:source], 'direct')
      ).to eq 'direct'
    end
  end
end