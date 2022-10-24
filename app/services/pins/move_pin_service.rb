module Pins
  class MovePinService
    include BaseService

    attr_reader :user, :pin, :is_from_author

    def initialize(user:, pin:, is_from_author:)
      @user = user
      @pin = pin
      @is_from_author = is_from_author
    end

    def self.move_up(user:, pin:, is_from_author:)
      instance = new(user: user, pin: pin, is_from_author: is_from_author)
      is_from_author ? instance.move_up_author_page : instance.move_up_index_page
    end

    def self.move_down(user:, pin:, is_from_author:)
      instance = new(user: user, pin: pin, is_from_author: is_from_author)
      is_from_author ? instance.move_down_author_page : instance.move_down_index_page
    end

    # -----

    def move_up_author_page
      next_element = pins_selector(collection: author_pins, up: true)
      return no_element_error if next_element.nil?

      call(next_element)
    end

    def move_down_author_page
      previous_element = pins_selector(collection: author_pins, up: false)
      return no_element_error if previous_element.nil?

      call(previous_element)
    end

    # ------

    def move_up_index_page
      next_element = pins_selector(collection: user.pins, up: true)
      return no_element_error if next_element.nil?

      call(next_element)
    end

    def move_down_index_page
      previous_element = pins_selector(collection: user.pins, up: false)
      return no_element_error if previous_element.nil?

      call(previous_element)
    end

    private

    def call(element)
      swap(element)
      struct_object(success: true, instance: pin)
    end

    def no_element_error
      struct_object(success: false, errors: I18n.t('pins.service.no_element'))
    end

    def author_pins
      user&.pins&.includes(:post)&.where(post: { user_id: pin.post.author.id})&.order(position: :asc)
    end

    def pins_selector(collection:, up:)
      if up
        collection.where('position < ?', pin.position).order("position ASC").last
      else
        collection.where('position > ?', pin.position).order("position ASC").first
      end
    end

    def swap(element)
      element.position, pin.position = pin.position, element.position
      [element, pin].each(&:save!)
    end
  end
end
