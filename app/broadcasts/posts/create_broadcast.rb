# frozen_string_literal: true

module Posts
  class CreateBroadcast < ApplicationService
    attr_reader :post, :user

    def initialize(params)
      super

      @post = params[:post]
      @user = params[:user]
    end

    def call
      broadcast_later :feed,
                      'posts/streams/post_prepended',
                      locals: { post: post, user: user, pin: nil, author: false }
    end
  end
end
