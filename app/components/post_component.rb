# frozen_string_literal: true

class PostComponent < ViewComponent::Base
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  renders_one :pinned_actions
  renders_one :author_actions
  renders_one :present_window
  renders_one :read_more

  attr_reader :post, :current_user, :pin, :author

  def initialize(post:, current_user:, pin:, author:)
    @post = post
    @current_user = current_user
    @pin = pin
    @author = author
  end

  def pin_id
    pin? ? pin.id : nil
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
