module Clients
  class CreateClient
    def initialize(params)
      @params = params
    end

    def call
      client = Client.new(@params)
      if client.save
        RegistrarEventoAuditoriaJob.perform_later(
          servicio_origen: "clientes",
          accion: "CREAR_CLIENTE",
          detalle: client.as_json
        )
        client
      else
        RegistrarEventoAuditoriaJob.perform_later(
          servicio_origen: "clientes",
          accion: "ERROR_CREAR_CLIENTE",
          detalle: client.errors
        )
        raise ActiveRecord::RecordInvalid.new(client)
      end
    end
  end
end
