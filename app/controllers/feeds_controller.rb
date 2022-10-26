class FeedsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    sessions_index_handler

    @pins = params[:hide_pins] == '1' ? [] : current_user&.sorted_pins
    @pagy, @posts = pagy(Post.search(current_user, params),
                         items: params[:per_page] ||= 15,
                         link_extra: 'data-turbo-action="advance"')
  end

  def authors_publications
    session_author_handler

    author = User.find(params[:id])
    @pins = if params[:hide_pins] == '1'
              []
            else
              current_user&.sorted_pins&.includes(:post)&.where(post: { user_id: author.id })
            end
    @pagy, @posts = pagy(Post.where(user: author)
                             .search(current_user, params)
                             .without_user_pins(current_user),
                         items: params[:per_page] ||= 15,
                         link_extra: 'data-turbo-action="advance"')
  end

  private

  def sessions_index_handler
    session[:published] = params[:sort_by].to_s if params[:sort_by].present?
    params[:sort_by] = session[:published] || ''

    session[:hide_draft] = params[:hide_draft].to_s if params[:hide_draft].present?
    params[:hide_draft] = session[:hide_draft] || ''

    session[:hide_hidden] = params[:hide_hidden].to_s if params[:hide_hidden].present?
    params[:hide_hidden] = session[:hide_hidden] || ''

    session[:hide_pins] = params[:hide_pins].to_s if params[:hide_pins].present?
    params[:hide_pins] = session[:hide_pins] || ''
  end

  def session_author_handler
    session[:author_published] = params[:sort_by].to_s if params[:sort_by].present?
    params[:sort_by] = session[:author_published] || ''

    session[:author_hide_draft] = params[:hide_draft].to_s if params[:hide_draft].present?
    params[:hide_draft] = session[:author_hide_draft] || ''

    session[:author_hide_hidden] = params[:hide_hidden].to_s if params[:hide_hidden].present?
    params[:hide_hidden] = session[:author_hide_hidden] || ''

    session[:author_hide_pins] = params[:hide_pins].to_s if params[:hide_pins].present?
    params[:hide_pins] = session[:author_hide_pins] || ''
  end
end
