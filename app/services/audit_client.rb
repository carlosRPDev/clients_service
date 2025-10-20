require "httparty"

class AuditClient
  include HTTParty
  base_uri ENV.fetch("AUDIT_URL", "http://localhost:3002")

  def post_event(payload)
    response = self.class.post(
      "/api/v1/audit/events",
      body: { audit_event: payload }.to_json,
      headers: { "Content-Type" => "application/json" }
    )

    if response.success?
      Rails.logger.info("[AUDIT] Evento registrado: #{payload[:action]} (#{response.code})")
    else
      Rails.logger.warn("[AUDIT] Falló envío (#{response.code}): #{response.body}")
    end

    response
  rescue => e
    Rails.logger.error("Audit post failed: #{e.message}")
    nil
  end
end
