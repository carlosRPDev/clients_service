require "httparty"

class AuditoriaClient
  include HTTParty
  base_uri ENV.fetch("AUDIT_URL", "http://localhost:3002")

  def post_event(evento)
    self.class.post("/api/v1/auditoria/events", body: evento.to_json, headers: { "Content-Type" => "application/json" })
  rescue => e
    Rails.logger.error("Audit post failed: #{e.message}")
    nil
  end
end
