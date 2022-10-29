module Moveable
  extend ActiveSupport::Concern

  included do
    def move_up(user:)
      element = user.pins.where('position < ?', self.position).order("position ASC").last
      move_elements(element)
    end

    def move_down(user:)
      element = user.pins.where('position > ?', self.position).order("position ASC").first
      move_elements(element)
    end

    def author_pin_move_up(user:)
      element = author_pins(user).where('position < ?', self.position).order("position ASC").last
      move_elements(element)
    end

    def author_pin_move_down(user:)
      element = author_pins(user).where('position > ?', self.position).order("position ASC").first
      move_elements(element)
    end

    private

    def author_pins(user)
      user.pins.includes(:post).where(post: { user_id: self.post.author.id }).order(position: :asc)
    end

    def move_elements(element)
      return moveable_struct(success: false, errors: I18n.t('pins.service.no_element')) if element.nil?

      swap(element)
      moveable_struct(success: true, instance: self)
    end

    def moveable_struct(**kwargs)
      Struct.new(:success?, :instance, :errors)
            .new(kwargs[:success], kwargs[:instance], kwargs[:errors])
    end

    def swap(element)
      element.position, self.position = self.position, element.position
      [element, self].each(&:save!)
    end
  end
end
