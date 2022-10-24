module Actions
  class PinnedActionsComponent < ViewComponent::Base
    attr_reader :pin, :author

    def initialize(pin:, author:)
      @pin = pin
      @author = author
    end
  end
end
