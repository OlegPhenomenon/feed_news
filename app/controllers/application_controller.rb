class ApplicationController < ActionController::Base
  before_action :turbo_frame_request_variant
  before_action :authenticate_user!

  def turbo_frame_request_variant
    request.variant = :turbo_frame if turbo_frame_request?
  end
end
