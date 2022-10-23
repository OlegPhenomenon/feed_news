class FeedsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    session[:published] = params[:sort_by].to_s if params[:sort_by].present?
    params[:sort_by] = session[:published] || ''

    @posts = Post.search(current_user, params)
  end

  def authors_publications
    author = User.find(params[:id])
    @posts = Post.where(user: author, status: 2)
  end
end
