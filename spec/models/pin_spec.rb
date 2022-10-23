require 'rails_helper'

RSpec.describe Pin, type: :model do
  describe 'validations' do
    let(:user) { create(:user) }
    let(:post) { create(:post) }
    let(:pin1) { build(:pin) }
    let(:pin2) { build(:pin) }

    it 'should not create pin duplicates for current user' do
      pin1.user = user
      pin1.post = post

      expect(pin1).to be_valid
      expect(pin1.save).to be true

      pin2.user = user
      pin2.post = post
      expect(pin2).to_not be_valid
      expect(pin2.errors.messages[:user_id]).to include(I18n.t('pins.errors.duplicate_pin'))
    end
  end
end
