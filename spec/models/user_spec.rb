RSpec.describe User, type: :model do
  include AlmaUserStubs
  subject { User.new 'testuser' }
  context 'faculty express status check' do
    context 'looks up status from Alma API' do
      it 'returns false when appropriate' do
        stub_alma_non_facex_user
        expect(subject.faculty_express?).to be_falsey
      end
      it 'returns true when appropriate' do
        stub_alma_facex_user
        expect(subject.faculty_express?).to be_truthy
      end
    end
  end
end