module Actions
  class AuthorActionsComponent < ViewComponent::Base
    attr_reader :post

    def initialize(post:)
      @post = post
    end

    def render?
      !post.disable_edit
    end
  end
end
