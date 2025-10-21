module ApiResponder
  extend ActiveSupport::Concern

  def render_success(data:, status: :ok)
    render json: { status: "success", data: data }, status: status
  end

  def render_error(message:, status: :unprocessable_entity)
    render json: { status: "error", message: message }, status: status
  end

  def render_not_found(resource = "Recurso")
    render json: { status: "error", message: "#{resource} no encontrado" }, status: :not_found
  end
end
