# frozen_string_literal: true

class PostComponent < ViewComponent::Base
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  renders_one :avatar, ->(post:) do
    Common::AvatarComponent.new(post: post)
  end
  renders_one :pinned_actions, ->(pin:, author:) do
    Actions::PinnedActionsComponent.new(pin: pin, author: author)
  end
  renders_one :author_actions, ->(post:) do
    Actions::AuthorActionsComponent.new(post: post)
  end
  renders_one :present_window, ->(post:) do
    Common::PresenterComponent.new(post: post)
  end
  renders_one :read_more, ->(post:) do
    Common::ReadMoreComponent.new(post: post)
  end

  attr_reader :post, :current_user, :pin, :author

  def initialize(post:, current_user:, pin:, author:)
    @post = post
    @current_user = current_user
    @pin = pin
    @author = author
  end

  def pin?
    @pin.present?
  end

  def current_user_is_author?
    current_user == post.author
  end

  def post_budget
    if post.published?
      content_tag :span do
        "Published at <u>#{post.published_at.to_formatted_s(:short)}</u> by
          <a href=#{authors_publications_path(id: post.user.id)} target='_top'>#{post.user.username}</a>".html_safe
      end
    else
      content_tag(:span, post.status, class: 'badge bg-secondary') +
        content_tag(:span) do
          "Created at <u>#{post.created_at.to_formatted_s(:short)}</u> by
            <a href=#{authors_publications_path(id: post.user.id)} target='_top'>#{post.user.username}</a>".html_safe
        end
    end
  end
end
