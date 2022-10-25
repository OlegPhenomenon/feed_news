class PostsController < ApplicationController
  include Pagy::Frontend

  before_action :set_post, only: %i[edit update destroy]

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build post_params
    authorize! :create, @post

    if @post.save
      Posts::CreateBroadcast.call({
                                    post: @post,
                                    user: @post.user
                                  }) if @post.published?
      redirect_to root_path, notice: I18n.t('posts.controller.created')
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = @post.errors.full_messages.join('; ')
          render turbo_stream: [
            render_turbo_flash
          ]
        end
      end
    end
  end

  def edit; end

  def update
    authorize! :update, @post

    if @post.update post_params
      redirect_to root_path, notice: I18n.t('posts.controller.updated')
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = @post.errors.full_messages.join('; ')
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
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :status, images: [])
  end
end
