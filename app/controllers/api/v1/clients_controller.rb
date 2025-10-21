module Api
  module V1
    class ClientsController < ApplicationController
      def index
        # render json: Client.all
        render_success(data: Client.all)
      end

      def show
        client = Client.find(params[:id])
        RegisterEventAuditJob.perform_later(
          origin_service: "clientes",
          action: "CONSULTA_CLIENTE",
          detail: client.as_json
        )
        render_success(data: client)
      rescue ActiveRecord::RecordNotFound
        RegisterEventAuditJob.perform_later(origin_service: "clientes", action: "ERROR_CONSULTA", detail: { id: params[:id] }, state: "NOT_FOUND")
        render_not_found("Cliente")
      rescue => e
        Rails.logger.error("[Clients] Error al consultar cliente: #{e.message}")
        render_error(message: "Error al obtener cliente", status: :internal_server_error)
      end

      def create
        client = CreateClient.new(client_params).call
        render_success(data: client, status: :created)
      rescue ActiveRecord::RecordInvalid => e
        render_error(message: e.message)
      end

      def update
        client = Client.find(params[:id])
        if client.update(client_params)
          RegisterEventAuditJob.perform_later(origin_service: "clientes", action: "ACTUALIZAR_CLIENTE", detail: client.as_json)
          render_success(data: client, status: :ok)
        else
          RegisterEventAuditJob.perform_later(origin_service: "clientes", action: "ERROR_ACTUALIZAR_CLIENTE", detail: client.errors, state: "FAILED")
          render_error(message: e.message)
        end
      end

      def destroy
        client = Client.find(params[:id])
        client.destroy
        RegisterEventAuditJob.perform_later(origin_service: "clientes", action: "ELIMINAR_CLIENTE", detail: { id: client.id })
        head :no_content
      end

      private

      def client_params
        params.require(:client).permit(:name, :identification, :email, :address)
      end
    end
  end
end
