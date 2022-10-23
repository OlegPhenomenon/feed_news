module Pins
  class MovePinService
    include BaseService

    attr_reader :user, :pin

    def initialize(user:, pin:)
      @user = user
      @pin = pin
    end

    def self.move_up(user:, pin:)
      new(user: user, pin: pin).move_up
    end

    def move_up
      next_element = user.pins.where('position < ?', pin.position).order("position ASC").last
      return struct_object(success: false, errors: I18b.t('pins.service.no_element')) if next_element.nil?

      swap(next_element)
      struct_object(success: true, instances: pin)
    end

    def self.move_down(user:, pin:)
      new(user: user, pin: pin).move_down
    end

    def move_down
      previous_element = user.pins.where('position > ?', pin.position).order("position ASC").first
      return struct_object(success: false, errors: I18b.t('pins.service.no_element')) if previous_element.nil?

      swap(previous_element)
      struct_object(success: true, instances: pin)
    end

    private

    def swap(element)
      element.position, pin.position = pin.position, element.position
      [element, pin].each(&:save!)
    end
  end
end
