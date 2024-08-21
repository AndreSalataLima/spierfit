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

  # Redireciona para o dashboard do recurso após o cadastro
  def after_sign_up_path_for(resource)
    case resource
    when Gym
      dashboard_gym_path(resource) # Ajuste para o dashboard do Gym
    when User
      dashboard_user_path(resource) # Ajuste para o dashboard do User
    when Personal
      dashboard_personal_path(resource) # Ajuste para o dashboard do Personal
    else
      super
    end
  end

  # Redireciona para o caminho correto após atualização da conta
  def after_update_path_for(resource)
    case resource
    when Gym
      dashboard_gym_path(resource) # Ajuste para o dashboard do Gym
    when User
      dashboard_user_path(resource) # Ajuste para o dashboard do User
    when Personal
      dashboard_personal_path(resource) # Ajuste para o dashboard do Personal
    else
      super
    end
  end
end
