class RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :name, :phone, :address, :status, :date_of_birth, :height, :weight,
      :email, :password, :password_confirmation
    ])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :name, :phone, :address, :status, :date_of_birth, :height, :weight,
      :email, :password, :password_confirmation, :current_password
    ])
  end

  def after_sign_up_path_for(resource)
    case resource
    when Gym
      gym_path(resource)
    when User
      user_path(resource)
    when Personal
      personal_path(resource)
    else
      super
    end
  end

  def after_update_path_for(resource)
    case resource
    when Gym
      gym_path(resource)
    when User
      user_path(resource)
    when Personal
      personal_path(resource)
    else
      super
    end
  end
end
