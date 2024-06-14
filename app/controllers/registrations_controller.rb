class RegistrationsController < Devise::RegistrationsController
  # skip_before_action :require_no_authentication, only: [:create]
  before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :name, :location, :contact_info, :hours_of_operation, :equipment_list,
      :policies, :subscriptions, :photos, :events, :capacity, :safety_protocols,
      :email, :password, :password_confirmation
    ])
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(Gym)
      gym_path(resource)
    elsif resource.is_a?(User)
      user_path(resource)
    elsif resource.is_a?(Personal)
      personal_path(resource)
    else
      super
    end
  end
end
