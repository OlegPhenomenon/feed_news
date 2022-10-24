module Common
  class PresenterComponent < ViewComponent::Base
    attr_reader :post

    def initialize(post:)
      @post = post
    end
  end
end