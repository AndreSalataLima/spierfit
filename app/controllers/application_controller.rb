class ApplicationController < ActionController::Base
  # before_action :ensure_https

  # def ensure_https
  #   if request.headers['X-Forwarded-Proto'] != 'https'
  #     redirect_to protocol: 'https://', status: :moved_permanently
  #   end
  # end

end
