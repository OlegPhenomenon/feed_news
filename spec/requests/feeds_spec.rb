require 'rails_helper'

RSpec.describe "Feeds", type: :request do
  describe 'index' do
    let(:user) { create(:user) }
    let(:post1) { create(:post) }
    let(:post2) { create(:post) }
    let(:post3) { create(:post) }

    it 'should render all posts if user their author' do
      # post2.update!(status: 1)
      # post3.update!(status: 2)

      # get '/'

      # expect(response).to render_template(:index)
      # expect(response.body).to include post1.title
    end 
  end
end
