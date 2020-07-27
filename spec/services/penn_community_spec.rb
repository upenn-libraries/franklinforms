require 'rails_helper'

RSpec.describe PennCommunity, type: :model do
  let(:service) { PennCommunity }
  context '#user_info_for' do
    context 'error conditions' do
      it 'raises an exception if no username param' do
        expect { service.get_user_info(nil) }.to raise_exception StandardError
      end
      it 'raises an exception if an invalid username is provided' do
        expect { service.get_user_info('username10') }.to raise_exception StandardError
      end
    end
  end
  context '#parse_query_results' do
    let(:results) { instance_double DBI::StatementHandle }
    let(:column_names) do
      %w[PENN_ID AFFILIATION_ACTIVE_CODE AFFILIATION_CODE PENNKEY_ACTIVE_CODE PENNKEY
         FIRST_NAME MIDDLE_NAME LAST_NAME EMAIL ORG_ACTIVE_CODE ORG_CODE DEPT RANK]
    end
    let(:row_1) do
      [12345678, 'A', 'STAF', 'A', 'bfranklin', 'Ben', nil, 'Franklin',
       'bfranklin@upenn.edu', 'A-F', '5008', 'Library Computing Systems                                   ',
       'Staff']
    end
    # TODO: get some other PCOM data
    let(:row_2) do
      [12345678, 'A', 'FAC', 'A', 'bfranklin', 'Ben', nil, 'Franklin',
       'bfranklin@upenn.edu', 'A-F', '5008', 'Wharton Online School of Thought Leadership',
       'Staff']
    end
    before do
      allow(results).to receive(:column_names).and_return column_names
      allow(results).to receive(:each).and_yield(row_1).and_yield(row_2)
    end
    it 'returns a hash of user info with information from query results' do
      user_info = service.parse_query_results results
      expect(user_info).to be_a Hash
      expect(user_info.keys).to include(*column_names.map(&:downcase))
      expect(user_info['penn_id'].length).to eq 2
    end
  end
  context '#clean_up' do
    let(:soiled_user_info) do
      {
        'penn_id' => %w[12345678 12345678],
        'affiliation_active_code' => %w[A A],
        'affiliation_code' => %w[STAF FAC],
        'pennkey_active_code' => %w[A A],
        'pennkey' => %w[bfranklin bfranklin],
        'first_name' => %w[Benjamin Ben],
        'middle_name' => ['', ''],
        'last_name' => %w[Franklin Franklin],
        'email' => %w[bfranklin@upenn.edu bfranklin@upenn.edu],
        'org_active_code' => %w[A-F A-F],
        'org_code' => %w[5008 9876],
        'dept' => ['Library Computing Systems', 'Wharton Online School of Thought Leadership'],
        'rank' => %w[Staff Faculty]
      }
    end
    it 'removes blank and duplicate values from user_info' do
      cleaned_up = service.clean_up soiled_user_info
      expect(cleaned_up['penn_id']).to be_a String
      expect(cleaned_up['dept'].length).to eq 2
      expect(cleaned_up['first_name']).to eq 'Benjamin'
    end
  end
end
