class RegistrationsController < Devise::RegistrationsController
  before_action :configure_account_update_params, only: %i[edit update]
  before_action :configure_permitted_parameters, only: %i[new create], if: :devise_controller?

  protected

  def update_resource(resource, account_update_params)
    resource.update_without_password(account_update_params)
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, except: %i[current_password password])
  end

  def account_update_params
    params.fetch(:user, {}).permit(:username, :email, :avatar)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[username email password password_confirmation avatar])
  end

  # def user_root_path
  #   user_path(current_user)
  # end
end
