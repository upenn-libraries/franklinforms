require 'rails_helper'

RSpec.feature 'Form rendering and submission', type: :feature do
  before do
    # Mock Illiad interactions
    allow(Illiad).to receive(:getIlliadUserInfo).and_return nil
    allow(Illiad).to receive(:addIlliadUser).and_return nil
    allow(Illiad).to receive(:updateIlliadUser).and_return nil
    allow(Illiad).to receive(:submit).and_return 'test_tx_number'
  end
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
    scenario 'upon submission, sends and email and renders confirmation' do
      visit form_path({ id: 'ill', requesttype: 'ScanDelivery' }.merge(book_params))
      # fill in required fields even though they are only required by JS
      test_email = 'test@upenn.edu'
      fill_in 'Email', with: test_email
      fill_in 'Article/Chapter Title', with: 'Other Selves and the Human World'
      fill_in 'Issue Date', with: '1945'
      click_on 'Submit Request'
      expect(ActionMailer::Base.deliveries.length).to eq 1
      mail = ActionMailer::Base.deliveries.first
      expect(mail.subject).to eq 'Request Confirmation'
      expect(mail.to).to eq [test_email]
      expect(page.current_path).to eq form_path(id: 'ill')
      expect(page).to have_text 'Your request has been submitted'
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
