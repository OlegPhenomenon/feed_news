require 'rails_helper'

RSpec.describe PinsController, type: :controller do
  describe 'up tp' do
    let(:pin) { create(:pin) }
    let(:pin2) { create(:pin) }
    let(:user) { create(:user) }
    let(:user_post) { create(:post) }

    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end

    it 'should up to position (0 is top)' do
      pin.update(position: 1, user: user)
      pin2.update(position: 0, user: user)
      patch :up_to, params: { id: pin.id }, format: :turbo_stream
      pin.reload
      pin2.reload

      expect(pin.position).to eq(0)
      expect(pin2.position).to eq(1)
    end

    it 'should down to position' do
      pin.update(position: 0, user: user)
      pin2.update(position: 1, user: user)
      patch :down_to, params: { id: pin.id }, format: :turbo_stream
      pin.reload
      pin2.reload

      expect(pin.position).to eq(1)
      expect(pin2.position).to eq(0)
    end

    it 'should create a new pin' do
      expect { post :create, params: { post_id: user_post.id }, format: :turbo_stream }
        .to change { Pin.count }.by(1)
    end

    it 'should remove existed pin' do
      pin.update(position: 0, user: user)

      expect { delete :destroy, params: { id: pin.id }, format: :turbo_stream }
        .to change { Pin.count }.by(-1)
    end
  end
end
