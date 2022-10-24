module Pins
  class CreateService
    include BaseService

    attr_reader :user, :post_id

    def initialize(user:, post_id:)
      @user = user
      @post_id = post_id
    end

    def self.call(user:, post_id:)
      new(user: user, post_id: post_id).call
    end

    def call
      pin = Pin.new user: user, post_id: post_id
      pin.position = user.pins? ? user.pins.maximum(:position) + 1 : 0
      pin.bg_color = bg_colors.sample

      pin.save ? struct_object(success: true, instance: pin) : struct_object(success: false, errors: pin.errors.full_messages.join('; '))
    end

    def bg_colors
      [
        '#74b9ff',
        '#a29bfe',
        '#81ecec',
        '#dfe6e9',
        '#ffeaa7',
        '#ff7675',
        '#55efc4',
        '#fab1a0',
        '#fdcb6e',
        '#fd79a8'
      ]
    end
  end
end
