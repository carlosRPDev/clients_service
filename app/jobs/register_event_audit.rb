class RegisterEventAuditJob < ApplicationJob
  queue_as :default

  def perform(origin_service:, action:, detail:, state: "OK")
    payload = {
      timestamp: Time.current.utc.iso8601,
      origin_service: origin_service,
      action: action,
      detail: detail,
      state: state
    }

    AuditClient.new.post_event(payload)
  rescue => e
    Rails.logger.error("Failed to send audit event: #{e.message}")
    raise e
  end
end
