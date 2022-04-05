# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Form rendering and submission', type: :feature do
  include AlmaUserStubs
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
    before do
      stub_alma_non_facex_user
    end
    scenario 'the form is rendered as expected using param data' do
      visit form_path({ id: 'ill', requesttype: 'ScanDelivery' }.merge(book_params))
      expect(page).to have_text 'Bibliographic information for the item requested'
      expect(page).to have_field 'Journal/Book Title', with: 'Phenomenology of perception /'
      expect(page).to have_field 'ISBN/ISSN', with: '0415834333'
    end
    context 'problematic date parsing' do
      let(:problematic_pubmed_article_params) do
        {
          'rft.epage': '139',
          'rft.volume': '39',
          'rft.stitle': 'Hospitalpractice.',
          'rft.issue_start': '3',
          'rft.place': 'Minneapolis',
          'rft.aufirst': 'Catherine C',
          'rft.genre': 'article',
          'rft.normalized_eissn': '2154-8331',
          'rft.normalized_issn': '2154-8331',
          'rft.doi': '10.3810%2Fhp.2011.08.588',
          'rft.year': '2011',
          rft_id: 'pmid%3A21881400',
          'rft.issue': '3',
          'rft.aulast': 'Cibulskis',
          'rft.object_type': 'JOURNAL',
          'rft.auinit': 'CC',
          'rft.date': '20118',
          ctx_id: '36662190890003681',
          'rft.title': 'Hospital+practice.',
          'rft.pub': 'McGraw-Hill+Healthcare+Publications%2C',
          'rft.jtitle': 'Hospital+practice.',
          'rft.spage': '128',
          'rft.oclcnum': '10716242',
          'rft.issn': '2154-8331',
          'rft.mms_id': '99144333503681',
          'rft.month': '8',
          rfr_id: 'Entrez%3APubMed',
          'rft.pmid': '21881400',
          'rft.publisher': 'McGraw-Hill+Healthcare+Publications%2C',
          'rft.au': 'Cibulskis%2C+Catherine+C',
          'rft.pubdate': '1995-',
          'rft.atitle': 'Care+transitions+from+inpatient+to+outpatient+settings%3A+ongoing+challenges+and+emerging+best+practices.',
          'rft.eissn': '2154-8331'
        }
      end
      scenario 'the book form prepopulates the correct date' do
        visit form_path({ id: 'ill' }.merge(problematic_pubmed_article_params))
        expect(page).to have_field 'Publication Date', with: '2011'
      end
    end
  end
  context 'for cataloging errors' do
    before do
      stub_alma_non_facex_user
    end
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
    before do
      stub_alma_facex_user
    end
    scenario 'the form is rendered as expected using param data' do
      visit form_path({ id: 'ill', requesttype: 'book' }.merge(book_params))
      expect(page).to have_text 'Bibliographic information for the item requested'
      expect(page).to have_field 'Title', with: 'Phenomenology of perception /'
      expect(page).to have_field 'ISBN', with: '0415834333'
    end
  end
  context 'for Books by mail' do
    before do
      stub_alma_non_facex_user
    end
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
