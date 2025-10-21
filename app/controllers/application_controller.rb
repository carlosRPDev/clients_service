class ApplicationController < ActionController::API
  include ApiResponder

  rescue_from ActiveRecord::RecordNotFound, with: -> { render_not_found("Registro") }
  rescue_from StandardError, with: :handle_standard_error

  private

  def handle_standard_error(exception)
    Rails.logger.error("[Error] #{exception.class}: #{exception.message}")
    render_error(message: "Error interno del servidor", status: :internal_server_error)
  end
end
