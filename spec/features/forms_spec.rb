# frozen_string_literal: true

RSpec.feature 'Form rendering and submission', type: :feature do
  let(:book_params) do
    {
      rfe_dat: '729064964',
      rfr_id: '', 'rft.atitle': '',
      'rft.au': 'Merleau-Ponty, Maurice, 1908-1961.',
      'rft.aufirst': '', 'rft.auinit': '', 'rft.aulast': '', 'rft.date': '', 'rft.doi': '', 'rft.edition': '',
      'rft.eisbn': '', 'rft.eissn': '', 'rft.epage': '',
      'rft.genre': 'book',
      'rft.isbn': '0415834333',
      'rft.issn': '', 'rft.issue': '', 'rft.jtitle': '', 'rft.month': '', 'rft.number': '',
      'rft.place': 'Abingdon, Oxon;',
      'rft.pub': 'Routledge,',
      'rft.publisher': 'Routledge,',
      'rft.pubdate': '2012.',
      'rft.pubyear': '', 'rft.spage': '',
      'rft.stitle': 'Phenomenology of perception /',
      'rft.btitle': 'Phenomenology of perception /',
      'rft.title': 'Phenomenology of perception /',
      'rft.volume': '', 'test': '',
      'bibid': '9954537543503681',
      'rfr_id': 'info:sid/primo.exlibrisgroup.com'
    }
  end
  context 'for ILL' do
    scenario 'the form is rendered as expected using param data' do
      visit form_path({ id: 'ill', requesttype: 'ScanDelivery' }.merge(book_params))
      expect(page).to have_text 'Bibliographic information for the item requested'
      expect(page).to have_field 'Journal/Book Title', with: 'Phenomenology of perception /'
      expect(page).to have_field 'ISBN/ISSN', with: '0415834333'
    end
  end
  context 'for cataloging errors' do
    let(:cataloging_params) do
      {
        bibid: '9954537543503681', rfr_id: 'info:sid/primo.exlibrisgroup.com'
      }
    end
    scenario 'the form is rendered as expected using param data' do
      visit form_path({ id: 'enhanced' }.merge(cataloging_params))
      expect(page).to have_text 'Report error'
      expect(page).to have_field 'Title', with: 'Phenomenology of perception /'
    end
  end
  context 'for FacultyEXPRESS' do
    scenario 'the form is rendered as expected using param data' do
      visit form_path({ id: 'ill', requesttype: 'book' }.merge(book_params))
      expect(page).to have_text 'Bibliographic information for the item requested'
      expect(page).to have_field 'Title', with: 'Phenomenology of perception /'
      expect(page).to have_field 'ISBN', with: '0415834333'
    end
  end
  context 'for Books by mail' do
    let(:bbm_params) do
      { bibid: '9954537543503681' }
    end
    scenario 'the form is rendered as expected using param data' do
      visit form_path({ id: 'booksbymail' }.merge(bbm_params))
      expect(page).to have_text 'Bibliographic Information'
      expect(page).to have_field 'Title', with: 'Phenomenology of perception /'
      expect(page).to have_field 'Call Number', with: 'B2430.M3763P4713 2012'
    end
  end
end
