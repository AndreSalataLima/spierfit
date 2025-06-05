module Api
  module V1
    class BaseController < ActionController::API
      include DeviseTokenAuth::Concerns::SetUserByToken
      include ErrorHandler
      include Pundit::Authorization

    end
  end
end
