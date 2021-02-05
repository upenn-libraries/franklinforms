# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ParallelAlmaApi, type: :model do
  include MockAlmaApi

  before do
    stub_large_bib_get
    stub_large_bib_items_get_full
    stub_large_bib_items_get_partial
  end

  let(:bib) { described_class.new '9999' }

  context '.bib_object' do
    it 'returns an Alma::Bib' do
      expect(bib.bib_object).to be_an Alma::Bib
    end
  end

  context '.items' do
    it 'pulls and aggregates Alma::BibItems for the given MMS ID' do
      items = bib.items
      expect(items.length).to eq bib.total_items
      expect(items.first).to be_a Alma::BibItem
    end
  end
end
