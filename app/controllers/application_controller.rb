class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :turbo_frame_request_variant
  before_action :authenticate_user!

  def turbo_frame_request_variant
    request.variant = :turbo_frame if turbo_frame_request?
  end

  def render_turbo_flash
    turbo_stream.update('flash', partial: 'shared/flash')
  end
end
