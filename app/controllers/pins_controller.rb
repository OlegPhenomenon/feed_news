class PinsController < ApplicationController
  before_action :set_pin, only: [:up_to, :down_to, :destroy]

  def create
    p = Pin.new user: current_user, post_id: params[:post_id]

    if current_user.pins?
      p.position = current_user.pins.last.position + 1
    else
      p.position = 0
    end
    p.save!

    redirect_to root_path
  end

  def destroy
    @pin.destroy

    redirect_to root_path
  end

  def up_to
    redirect_to root_path and return if current_user.pins.empty? || current_user.pins.count.zero?
    redirect_to root_path and return if current_user.pins.minimum(:position) == @pin.position

    next_element = current_user.pins.where('position < ?', @pin.position).order("position ASC").last
    redirect_to root_path and return if next_element.nil?

    next_element.position, @pin.position = @pin.position, next_element.position
    [next_element, @pin].each(&:save!)

    redirect_to root_path
  end

  # next
  def down_to
    redirect_to root_path and return if current_user.pins.empty? || current_user.pins.count.zero?
    redirect_to root_path and return if current_user.pins.maximum(:position) == @pin.position

    previous_element = current_user.pins.where('position > ?', @pin.position).order("position ASC").first
    p '--'
    p previous_element.position
    p @pin.position
    p '--'
    redirect_to root_path and return if previous_element.nil?

    previous_element.position, @pin.position = @pin.position, previous_element.position
    [previous_element, @pin].each(&:save!)

    redirect_to root_path
  end

  private

  def set_pin
    @pin = Pin.find(params[:id])
  end
end