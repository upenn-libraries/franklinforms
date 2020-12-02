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
  context 'isomorphism with Illiad.getBibData' do
    # TODO test URLs from Summon, BD, Relais, etc
    context 'using Franklin links' do
      let :ill_params do
        querystring = 'rft.mms_id=994080073503681&rft.stitle=Wuthering+Heights+%2F&rft.pub=Penguin+Books%2C&rft.place=Harmondsworth%2C+Middlesex+%3A&rft.isbn=0410430016+%3A+%28paperb.%29+%3A&rft.btitle=Wuthering+Heights+%2F&rft.genre=book&rft.object_type=BOOK&rft.normalized_isbn=9780410430017&rft.publisher=Penguin+Books%2C&rft.au=Bronte%CC%88%2C+Emily%2C+1818-1848.&rft.pubdate=1975%2C+c1965.&rft.oclcnum=2724293&rft.title=Wuthering+Heights+%2F&requesttype=book&bibid=994080073503681&rfr_id=info%3Asid%2Fprimo.exlibrisgroup.com'
        Rack::Utils.parse_nested_query querystring
      end
      it 'to be equivalent where it matters' do
        request_bib = RequestBib.new(ill_params)
        ill_bib_data = Illiad.getBibData ill_params
        # expect(request_bib.to_h).to eq ill_bib_data
        expect(request_bib.author).to eq ill_bib_data['author']
        expect(request_bib.place).to eq ill_bib_data['place']
        expect(request_bib.article).to eq ill_bib_data['article']
        expect(request_bib.bib_id).to eq ill_bib_data['bibid']
        expect(request_bib.booktitle).to eq ill_bib_data['booktitle']
        expect(request_bib.spage).to eq ill_bib_data['spage']
        expect(request_bib.title).to eq ill_bib_data['title']
        expect(request_bib.year).to eq ill_bib_data['year']
        expect(request_bib.isbn).to eq ill_bib_data['isbn']
        expect(request_bib.sid).to eq ill_bib_data['sid']
        expect(request_bib.spage).to eq ill_bib_data['spage']
        expect(request_bib.pages).to eq ill_bib_data['pages']
        expect(request_bib.publisher).to eq ill_bib_data['publisher']
      end
    end
  end
end