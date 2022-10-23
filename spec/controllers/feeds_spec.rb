require 'rails_helper'

RSpec.describe FeedsController, type: :controller do
  describe 'index' do
    let(:user) { create(:user) }
    let(:post1) { create(:post) }
    let(:post2) { create(:post) }
    let(:post3) { create(:post) }

    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
    end

    it 'response should be succesfull' do
      get :index

      expect(response.status).to eq(200)
    end
  end
end
