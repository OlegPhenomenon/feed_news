class PinsController < ApplicationController
  include Pagy::Frontend

  before_action :set_pin, only: %i[up_to down_to destroy]
  before_action :validate_pins_count, only: %i[up_to down_to]
  before_action :validate_pin_poistion_up, only: [:up_to]
  before_action :validate_pin_poistion_down, only: [:down_to]

  def create
    result = Pins::CreateService.call(user: current_user, post_id: params[:post_id])

    respond_to do |format|
      format.turbo_stream do
        if result.success?
          flash.now[:notice] = I18n.t('pins.controller.created')

          session[:published] = params[:sort_by].to_s if params[:sort_by].present?
          params[:sort_by] = session[:published] || ''

          render turbo_stream: [
            render_turbo_flash,
            turbo_stream.remove(result.instance.post),
            turbo_stream.prepend('pins', partial: 'feeds/post', locals: { post: result.instance.post,
                                                                          pin: result.instance })
          ]
        else
          flash.now[:alert] = result.errors
          render turbo_stream: [
            render_turbo_flash
          ]
        end
      end

      format.html do
        if result.success?
          flash.now[:notice] = I18n.t('pins.controller.created')
        else
          flash.now[:alert] = result.errors
        end

        redirect_to request.referer
      end
    end
  end

  def destroy
    post = @pin.post

    respond_to do |format|
      format.turbo_stream do
        if @pin.destroy
          session[:published] = params[:sort_by].to_s if params[:sort_by].present?
          params[:sort_by] = session[:published] || ''
          @pagy, @posts = pagy(Post.search(current_user, params),
                               items: params[:per_page] ||= 15,
                               link_extra: 'data-turbo-action="advance"')

          render turbo_stream: [
            turbo_stream.remove(post),
            turbo_stream.update('posts', partial: 'feeds/posts', locals: { posts: @posts }),
            turbo_stream.update('pagy', html: pagy_nav(@pagy).to_s.html_safe)
          ]
        else
          flash.now[:alert] = result.errors
          render turbo_stream: [
            render_turbo_flash
          ]
        end
      end
    end
  end

  def up_to
    result = Pins::MovePinService.move_up(user: current_user, pin: @pin)
    rendering_move_result(result)
  end

  def down_to
    result = Pins::MovePinService.move_down(user: current_user, pin: @pin)
    rendering_move_result(result)
  end

  private

  def validate_pins_count
    redirect_to root_path and return if current_user.pins.empty? || current_user.pins.count.zero?
  end

  def validate_pin_poistion_down
    redirect_to root_path and return if current_user.pins.maximum(:position) == @pin.position
  end

  def validate_pin_poistion_up
    redirect_to root_path and return if current_user.pins.minimum(:position) == @pin.position
  end

  def rendering_move_result(result)
    respond_to do |format|
      format.turbo_stream do
        if result.success?
          @pins = current_user.pins.order(position: :asc)
          render turbo_stream: [
            turbo_stream.update('pins', partial: 'feeds/pins', locals: { pins: @pins })
          ]
        else
          flash.now[:alert] = result.errors
          render turbo_stream: [
            render_turbo_flash
          ]
        end
      end
    end
  end

  def set_pin
    @pin = Pin.find(params[:id])
  end
end
