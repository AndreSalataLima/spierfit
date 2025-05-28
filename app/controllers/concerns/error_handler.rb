module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
    rescue_from ActiveRecord::RecordNotUnique, with: :render_conflict
    rescue_from ActionController::ParameterMissing, with: :render_bad_request
    rescue_from Pundit::NotAuthorizedError, with: :render_forbidden if defined?(Pundit)
  end

  private

  def render_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def render_unprocessable_entity(exception)
    render json: { error: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def render_conflict(exception)
    render json: { error: "Registro duplicado: #{exception.message}" }, status: :conflict
  end

  def render_bad_request(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def render_forbidden(_exception)
    render json: { error: "Ação não autorizada." }, status: :forbidden
  end

end
