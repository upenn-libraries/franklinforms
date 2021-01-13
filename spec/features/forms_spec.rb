require 'rails_helper'

RSpec.feature 'Form rendering and submission', type: :feature do
  include MockAlmaApi
  before do
    stub_bib_get_success
  end
  let(:book_params) do
    {
      rfe_dat: '729064964',
      rfr_id: '', 'rft.atitle': '',
      'rft.au': 'Resnik, Michael D.',
      'rft.aufirst': '', 'rft.auinit': '', 'rft.aulast': '', 'rft.date': '', 'rft.doi': '', 'rft.edition': '',
      'rft.eisbn': '', 'rft.eissn': '', 'rft.epage': '',
      'rft.genre': 'book',
      'rft.isbn': '0198236085 (hb)',
      'rft.issn': '', 'rft.issue': '', 'rft.jtitle': '', 'rft.month': '', 'rft.number': '',
      'rft.place': 'Oxford : New York :',
      'rft.pub': 'Clarendon',
      'rft.publisher': 'Clarendon',
      'rft.pubdate': '1997.',
      'rft.pubyear': '', 'rft.spage': '',
      'rft.stitle': 'Mathematics as a science of patterns /',
      'rft.btitle': 'Mathematics as a science of patterns /',
      'rft.title': 'Mathematics as a science of patterns /',
      'rft.volume': '', 'test': '',
      'bibid': '1234',
      'rfr_id': 'info:sid/primo.exlibrisgroup.com'
    }
  end
  context 'for ILL' do
    scenario 'the form is rendered as expected using param data' do
      visit form_path({ id: 'ill', requesttype: 'ScanDelivery' }.merge(book_params))
      expect(page).to have_text 'Bibliographic information for the item requested'
      expect(page).to have_field 'Journal/Book Title', with: 'Mathematics as a science of patterns /'
      expect(page).to have_field 'ISBN/ISSN', with: '0198236085 (hb)'
    end
  end
  context 'for cataloging errors' do
    let(:cataloging_params) do
      {
        bibid: '1234', rfr_id: 'info:sid/primo.exlibrisgroup.com'
      }
    end
    scenario 'the form is rendered as expected using param data' do
      visit form_path({ id: 'enhanced' }.merge(cataloging_params))
      expect(page).to have_text 'Report error'
      expect(page).to have_field 'Title', with: 'Mathematics as a science of patterns /'
    end
  end
  context 'for FacultyEXPRESS' do
    scenario 'the form is rendered as expected using param data' do
      visit form_path({ id: 'ill', requesttype: 'book' }.merge(book_params))
      expect(page).to have_text 'Bibliographic information for the item requested'
      expect(page).to have_field 'Title', with: 'Mathematics as a science of patterns /'
      expect(page).to have_field 'ISBN', with: '0198236085 (hb)'
    end
  end
  # Books by mail requests are now submitted via the ILL form
  # context 'for Books by mail' do
  #   let(:bbm_params) do
  #     { bibid: '1234' }
  #   end
  #   scenario 'the form is rendered as expected using param data' do
  #     visit form_path({ id: 'booksbymail' }.merge(bbm_params))
  #     expect(page).to have_text 'Bibliographic Information'
  #     expect(page).to have_field 'Title', with: 'Mathematics as a science of patterns /'
  #     expect(page).to have_field 'Call Number', with: 'B2430.M3763P4713 2012'
  #   end
  # end
end
