class PinsController < ApplicationController
  before_action :set_pin, only: [:up_to, :down_to, :destroy]

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
            turbo_stream.append('pins', partial: 'feeds/post', locals: { post: result.instance.post,
                                                                         pin: result.instance })
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
            turbo_stream.update('posts', partial: 'feeds/posts', locals: { posts: @posts })
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