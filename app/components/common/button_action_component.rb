module Common
  class ButtonActionComponent < ViewComponent::Base
    attr_reader :method, :url, :color

    def initialize(method:, url:, color:)
      @method = method
      @url = url
      @color = color
    end
  end
end