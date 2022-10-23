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
      pin.position = user.pins? ? user.pins.last.position + 1 : 0

      pin.save ? struct_object(success: true, instance: pin) : struct_object(success: true, errors: pin.errors.full_messages.join('; '))
    end
  end
end
