module Api
  module V1
    class ClientsController < ApplicationController
      def index
        render json: Client.all
      end

      def show
        client = Client.find(params[:id])
        RegisterEventAuditJob.perform_later(
          origin_service: "clientes",
          action: "CONSULTA_CLIENTE",
          detail: client.as_json
        )
        render json: client
      rescue ActiveRecord::RecordNotFound
        RegisterEventAuditJob.perform_later(origin_service: "clientes", action: "ERROR_CONSULTA", detail: { id: params[:id] }, state: "NOT_FOUND")
        render json: { error: "Cliente no encontrado" }, status: :not_found
      end

      def create
        client = Clients::CreateClient.new(client_params).call
        render json: client, status: :created
      rescue ActiveRecord::RecordInvalid => e
          render json: e.record.errors, status: :unprocessable_entity
      end

      def update
        client = Client.find(params[:id])
        if client.update(client_params)
          RegisterEventAuditJob.perform_later(origin_service: "clientes", action: "ACTUALIZAR_CLIENTE", detail: client.as_json)
          render json: client
        else
          RegisterEventAuditJob.perform_later(origin_service: "clientes", action: "ERROR_ACTUALIZAR_CLIENTE", detail: client.errors, state: "FAILED")
          render json: client.errors, status: :unprocessable_entity
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
