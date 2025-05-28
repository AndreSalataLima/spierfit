module Api
  module V1
    module Auth
      class SessionsController < DeviseTokenAuth::SessionsController
        # skip_before_action :verify_authenticity_token, raise: false
      end
    end
  end
end
