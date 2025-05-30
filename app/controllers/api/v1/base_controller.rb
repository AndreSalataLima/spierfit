module Api
  module V1
    class BaseController < ActionController::API
      include DeviseTokenAuth::Concerns::SetUserByToken
      include ErrorHandler
      include Pundit

      # skip_before_action :verify_authenticity_token

      private

    end
  end
end
