require 'rails_helper'

RSpec.describe AlmaRecord, type: :model do
  include MockAlmaApi
  describe '#initialize' do
    context 'for a single item book holding' do
      let(:mms_id) { '1234' }
      let(:record) do
        AlmaRecord.new mms_id
      end
      before do
        stub_bib_get_success
        stub_items_get_success
      end
      it 'has a bib_data hash' do
        expect(record.bib_data).to be_a Hash
      end
      it 'has an array of AlmaHoldings' do
        expect(record.holdings.first).to be_a AlmaHolding
      end
      it 'has an array of Alma:BibItems' do
        expect(record.items.first).to be_a Alma::BibItem
      end
    end
    context 'for a complex record with many holdings' do
      let(:mms_id) { '1111' }
      let(:record) do
        AlmaRecord.new mms_id
      end
      before do
        stub_complex_bib_get_success
      end
      it 'has a bib_data hash' do
        expect(record.bib_data).to be_a Hash
      end
      it 'has an array of AlmaHoldings' do
        expect(record.holdings).to be_an Array
        expect(record.holdings.first).to be_a AlmaHolding
      end
      it 'does not set Items' do
        expect(record.items).to be_nil
      end
    end
    context 'with a holding specified' do
      let(:mms_id) { '1111' }
      let(:holding_id) { '2222' }
      let(:record) do
        AlmaRecord.new mms_id, holding_id: holding_id
      end
      before do
        stub_complex_bib_get_success
        stub_complex_items_get_success
      end
      it 'has an array of Items' do
        expect(record.items).to be_an Array
        expect(record.items.first).to be_a Alma::BibItem
      end
    end
  end
end