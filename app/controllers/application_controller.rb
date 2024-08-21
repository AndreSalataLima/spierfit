class ApplicationController < ActionController::Base
  # O resto do seu código existente

  protected

  def after_sign_in_path_for(resource)
    case resource
    when User
      dashboard_user_path(resource)
    when Gym
      dashboard_gym_path(resource)  # Assume que esta seja a rota correta
    when Personal
      dashboard_personal_path(resource)  # Assume que esta seja a rota correta
    else
      super  # Redireciona para a raiz ou outro caminho padrão para outros tipos de recursos
    end
  end

end
