class CreateClient
  def initialize(params)
    @params = params
  end

  def call
    client = Client.new(@params)
    if client.save
      RegisterEventAuditJob.perform_later(
        origin_service: "clientes",
        action: "CREAR_CLIENTE",
        detail: client.as_json
      )
      client
    else
      RegisterEventAuditJob.perform_later(
        origin_service: "clientes",
        action: "ERROR_CREAR_CLIENTE",
        detail: client.errors,
        state: "FAILED"
      )
      raise ActiveRecord::RecordInvalid.new(client)
    end
  end
end
