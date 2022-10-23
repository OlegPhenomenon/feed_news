class FeedsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    session[:published] = params[:sort_by].to_s if params[:sort_by].present?
    params[:sort_by] = session[:published] || ''

    @pins = current_user.pins.order(position: :asc)
    @pagy, @posts = pagy(Post.search(current_user, params),
                         items: params[:per_page] ||= 15,
                         link_extra: 'data-turbo-action="advance"')
  end

  def authors_publications
    session[:author_published] = params[:sort_by].to_s if params[:sort_by].present?
    params[:sort_by] = session[:author_published] || ''

    author = User.find(params[:id])
    @pagy, @posts = pagy(Post.where(user: author, status: 2).search(current_user, params),
                         items: params[:per_page] ||= 15,
                         link_extra: 'data-turbo-action="advance"')
  end
end
