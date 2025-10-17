class RegistrarEventoAuditoriaJob < ApplicationJob
  queue_as :default

  def perform(evento)
    AuditoriaClient.new.post_event(evento)
  rescue => e
    Rails.logger.error("Failed to send audit event: #{e.message}")
    raise e
  end
end
