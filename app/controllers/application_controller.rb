class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken

  protected

  def after_sign_in_path_for(resource)
    case resource
    when User
      dashboard_user_path(resource)
    when Gym
      dashboard_gym_path(resource)
    when Personal
      dashboard_personal_path(resource)
    else
      super
    end
  end

end
