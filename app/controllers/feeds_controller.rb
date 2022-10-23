class FeedsController < ApplicationController
  def index
    session[:published] = params[:sort_by].to_s if params[:sort_by].present?
    params[:sort_by] = session[:published] || ''

    @posts = Post.search(current_user, params)
  end
end
