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

  def post_updated_at
    return if post.published_at.nil?
    return unless post.updated_at > post.published_at + 1.minute

    content_tag(:span, "Post updated  at #{post.updated_at.to_formatted_s(:short)}", class: 'badge rounded-pill bg-warning text-dark')
  end

  def post_created_at
    return unless current_user_is_author?

    tag.span do
      " | Created at <u>#{post.created_at.to_formatted_s(:short)}</u> |".html_safe
    end
  end
end
