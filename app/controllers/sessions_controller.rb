# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    super

    # respond_to do |format|
    #   format.turbo_stream do 
    #     # render turbo_stream: turbo_stream.update('modal', partial: "posts/form", locals: {post: @post})
    #     render turbo_stream: turbo_stream.update('modal', template: "devise/sessions/new", locals: {resource: resource})
    #   end
    # end
  end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
