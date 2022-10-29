class PostsController < ApplicationController
  include Pagy::Frontend

  before_action :set_post, only: %i[edit update destroy]

  def new
    @post = Post.new(user: current_user)

    authorize! :manage, @post
  end

  def create
    result = Posts::CreateService.call(user: current_user, params: post_params)

    if result.success?
      post = result.instance

      post.disable_edit = true
      Posts::CreateBroadcast.call({
                                    post: post,
                                    user: post.user
                                  }) if post.published?
      redirect_to root_path, notice: I18n.t('posts.controller.created')
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = result.errors
          render turbo_stream: [
            render_turbo_flash
          ]
        end
      end
    end
  end

  def edit
    authorize! :edit, @post
  end

  def update
    authorize! :update, @post
    broadcast = post_params[:status] == 'published' && @post.published_at.nil?
    result = Posts::UpdateService.call(post: @post, params: post_params)

    if result.success?
      post = result.instance

      post.disable_edit = true
      Posts::CreateBroadcast.call({
                            post: post,
                            user: post.user
                          }) if broadcast
      redirect_to root_path, notice: I18n.t('posts.controller.updated')
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = result.errors
          render turbo_stream: [
            render_turbo_flash
          ]
        end
      end
    end
  end

  def destroy
    title = I18n.t('posts.controller.removed', value: @post.title.present? ? "title #{@post.title}" : "id #{@post.id}")
    authorize! :destroy, @post

    respond_to do |format|
      if @post.destroy
        flash.now[:alert] = title

        format.turbo_stream do
          render turbo_stream: [
            render_turbo_flash,
            turbo_stream.remove(@post)
          ]
        end
      else
        format.turbo_stream do
          flash.now[:alert] = @post.errors.full_messages.join('; ')
          render turbo_stream: [
            render_turbo_flash
          ]
        end
      end
    end
  end

  private

  def set_post
    @post = Post.accessible_by(current_ability).find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :status, images: [])
  end
end

