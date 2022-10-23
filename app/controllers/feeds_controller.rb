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

    # sql = "SELECT pins.* FROM pins WHERE user_id = #{author.id} INNER JOIN"
    @pins = current_user.pins.joins(:post).where(user_id: author.id)

    # @pins = ActiveRecord::Base.connection.execute(sql)
    @pagy, @posts = pagy(Post.where(user: author)
                             .search(nil, params)
                             .without_user_pins(current_user),
                         items: params[:per_page] ||= 15,
                         link_extra: 'data-turbo-action="advance"')
  end
end
