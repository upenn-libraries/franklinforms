require 'rails_helper'

# TODO: webmock
RSpec.describe AlmaRecord, type: :model do
  describe '#initialize' do
    context 'for a single item book holding' do
      let(:mms_id) { '9922327423503681' }
      let(:record) do
        AlmaRecord.new mms_id
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
      let(:mms_id) { '99123503681' }
      let(:record) do
        AlmaRecord.new mms_id
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
      let(:mms_id) { '99123503681' }
      let(:holding_id) { '22367148200003681' }
      let(:record) do
        AlmaRecord.new mms_id, holding_id: holding_id
      end
      it 'has an array of Items' do
        expect(record.items).to be_an Array
        expect(record.items.first).to be_a Alma::BibItem
      end
    end
  end
end