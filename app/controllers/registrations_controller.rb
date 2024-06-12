class RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  skip_before_action :require_no_authentication, only: [:create]

  # before_action :configure_account_update_params, only: [:update]

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :name, :email, :password, :password_confirmation,
      :phone, :address, :status, :date_of_birth,
      :height, :weight, :gym_id, :personal_id
    ])

  end

  def after_sign_up_path_for(resource)
    user_path(resource)
  end


  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:name, :phone, :address, :status, :date_of_birth, :height, :weight, :gym_id, :personal_id])
  # end

  # def create
  #   puts "create action reached!"
  #   @user = User.new(user_params)
  #   if @user.save
  #     flash[:notice] = "User created successfully!"
  #     redirect_to users_path
  #   else
  #     render :new
  #   end
  # end

end
