module Common
  class ReadMoreComponent < ViewComponent::Base
    attr_reader :post

    def initialize(post:)
      @post = post
    end

    def no_render_compomnent?
      post.content.body.attachables.count == 1 && !post.contain_plain_text?
    end
  end
end