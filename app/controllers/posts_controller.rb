class PostsController < ApplicationController
  before_action :set_post, only: [:edit, :update, :destroy]

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.create post_params.to_h

    redirect_to root_path
  end

  def edit; end

  def update
    @post.update post_params.to_h

    redirect_to root_path
  end

  def destroy
    @post.destroy

    redirect_to root_path
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :status, images: [])
  end
end
