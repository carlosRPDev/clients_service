class RegistrarEventoAuditoriaJob < ApplicationJob
  queue_as :default

  def perform(servicio_origen:, accion:, detalle:, estado: "OK")
    evento = {
      timestamp: Time.current.utc.iso8601,
      servicio_origen: servicio_origen,
      accion: accion,
      detalle: detalle,
      estado: estado
    }

    AuditoriaClient.new.post_event(evento)
  rescue => e
    Rails.logger.error("Failed to send audit event: #{e.message}")
    raise e
  end
end
