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
            turbo_stream.append('pins', partial: 'feeds/post', locals: { post: result.instance.post,
                                                                         pin: result.instance,
                                                                         author: params['author'] == 'true',
                                                                         user: current_user})
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
    authorize! :destroy, @pin

    post = @pin.post
    respond_to do |format|
      format.turbo_stream do
        if @pin.destroy
          session[:published] = params[:sort_by].to_s if params[:sort_by].present?
          params[:sort_by] = session[:published] || ''

          posts = if params['author'] == 'true'
                    Post.where(user: post.author)
                        .search(current_user, params)
                        .without_user_pins(current_user)
                  else
                    Post.search(current_user, params)
                  end

          @pagy, @posts = pagy(posts, items: params[:per_page] ||= 15, link_extra: 'data-turbo-action="advance"')
          flash.now[:notice] = I18n.t('pins.controller.destroyed')

          render turbo_stream: [
            render_turbo_flash,
            turbo_stream.remove(post),
            turbo_stream.update('posts', partial: 'feeds/posts', locals: { posts: @posts,
                                                                           author: params['author'] == 'true',
                                                                           user: current_user }),
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
    authorize! :up_to, @pin
    result = Pins::MovePinService.move_up(user: current_user, pin: @pin, is_from_author: params['author'] == 'true')

    rendering_move_result(result)
  end

  def down_to
    authorize! :down_to, @pin

    result = Pins::MovePinService.move_down(user: current_user, pin: @pin, is_from_author: params['author'] == 'true')
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
    author = @pin.post.author

    respond_to do |format|
      format.turbo_stream do
        if result.success?
          if params['author'] == 'true'
            @pins = current_user&.pins&.includes(:post)&.where(post: { user_id: author.id})&.order(position: :asc)
          else
            @pins = current_user.pins.order(position: :asc)
          end

          flash.now[:notice] = I18n.t('pins.controller.moved')
          render turbo_stream: [
            render_turbo_flash,
            turbo_stream.update('pins', partial: 'feeds/pins', locals: { pins: @pins,
                                                                         author: params['author'] == 'true',
                                                                         user: current_user })
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
