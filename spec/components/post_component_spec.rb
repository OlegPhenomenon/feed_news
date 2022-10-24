# frozen_string_literal: true

require "rails_helper"
require "view_component/test_case"

RSpec.describe PostComponent, type: :component do
  let(:post) { create(:post) }
  let(:user) { create(:user) }
  let(:second_user) { create(:user) }
  let(:pin) { create(:pin) }

  describe 'posts in index page' do
    it 'should render published post for author' do
      post.update(status: 2, user: user)
      user.reload
      post.reload
      render_inline(described_class.new(post: post, current_user: user, pin: nil, author: false))

      expect(page).to have_text post.title
      expect(page).to have_text post.user.username
      expect(page).to have_text post.published_at.to_formatted_s(:short)

      expect(page).to have_link post.user.username

      expect(page).to have_selector(:css, "a[href=\"#{authors_publications_path(id: post.user.id)}\"]")
      expect(page).to have_selector(:css, "a[href=\"#{edit_post_path(id: post.id)}\"]")
      expect(page).to have_selector(:css, "form[action=\"#{post_path(id: post.id)}\"]")
      expect(page).to have_selector(:css, "form[action=\"#{pins_path(post_id: post.id, author: false)}\"]")

      expect(page).not_to have_selector(:css, "a[href=\"#{up_to_pin_path(id: pin.id)}?author=false\"]")
    end

    it 'should render published post for signed user, but not its author' do
      post.update(status: 2, user: second_user)
      render_inline(described_class.new(post: post, current_user: user, pin: nil, author: false))

      expect(page).to have_text post.title
      expect(page).to have_text post.user.username
      expect(page).to have_text post.published_at.to_formatted_s(:short)

      expect(page).to have_link post.user.username

      expect(page).to have_selector(:css, "a[href=\"#{authors_publications_path(id: post.user.id)}\"]")
      expect(page).to have_selector(:css, "form[action=\"#{pins_path(post_id: post.id, author: false)}\"]")

      expect(page).not_to have_selector(:css, "a[href=\"#{edit_post_path(id: post.id)}\"]")
      expect(page).not_to have_selector(:css, "form[action=\"#{post_path(id: post.id)}\"]")

      expect(page).not_to have_selector(:css, "a[href=\"#{up_to_pin_path(id: pin.id)}?author=#{post.author}\"]")
    end

    it 'should render published post for non signed users' do
      logout
      post.update(status: 2)
      render_inline(described_class.new(post: post, current_user: nil, pin: nil, author: false))

      expect(page).to have_text post.title
      expect(page).to have_text post.user.username
      expect(page).to have_text post.published_at.to_formatted_s(:short)

      expect(page).to have_link post.user.username

      expect(page).not_to have_selector(:css, "a[href=\"#{edit_post_path(id: post.id)}\"]")
      expect(page).not_to have_selector(:css, "form[action=\"#{post_path(id: post.id)}\"]")
      expect(page).not_to have_selector(:css, "a[href=\"#{up_to_pin_path(id: pin.id)}?author=false\"]")
      expect(page).not_to have_selector(:css, "form[action=\"#{pins_path(post_id: post.id, author: false)}\"]")
    end
  end

  describe 'pins in index page' do
    it 'should render pin for its owner' do
      post.update(status: 2, user: user)
      pin.update(user: user, post: post)

      render_inline(described_class.new(post: post, current_user: user, pin: pin, author: false))

      expect(page).to have_text post.title
      expect(page).to have_text post.user.username
      expect(page).to have_text post.published_at.to_formatted_s(:short)

      expect(page).to have_selector(:css, "a[href=\"#{up_to_pin_path(id: pin.id)}?author=false\"]")
      expect(page).to have_selector(:css, "a[href=\"#{down_to_pin_path(id: pin.id)}?author=false\"]")
    end

    it 'should not render owner pin for guests & another users' do
      post.update(status: 2, user: user)
      pin.update(user: user, post: post)

      render_inline(described_class.new(post: post, current_user: nil, pin: pin, author: false))
      expect(page).to have_text post.title
      expect(page).to have_text post.user.username
      expect(page).to have_text post.published_at.to_formatted_s(:short)

      expect(page).not_to have_selector(:css, "a[href=\"#{up_to_pin_path(id: pin.id)}?author=false\"]")
      expect(page).not_to have_selector(:css, "a[href=\"#{down_to_pin_path(id: pin.id)}?author=false\"]")
    end
  end
end
