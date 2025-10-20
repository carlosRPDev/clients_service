module Api
  module V1
    class ClientsController < ApplicationController
      def index
        render json: Client.all
      end

      def show
        client = Client.find(params[:id])
        RegistrarEventoAuditoriaJob.perform_later(
          servicio_origen: "clientes",
          accion: "CONSULTA_CLIENTE",
          detalle: client.as_json
        )
        render json: client
      rescue ActiveRecord::RecordNotFound
        RegistrarEventoAuditoriaJob.perform_later(servicio_origen: "clientes", accion: "ERROR_CONSULTA", detalle: { id: params[:id] })
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
          RegistrarEventoAuditoriaJob.perform_later(servicio_origen: "clientes", accion: "ACTUALIZAR_CLIENTE", detalle: client.as_json)
          render json: client
        else
          RegistrarEventoAuditoriaJob.perform_later(servicio_origen: "clientes", accion: "ERROR_ACTUALIZAR_CLIENTE", detalle: client.errors)
          render json: client.errors, status: :unprocessable_entity
        end
      end

      def destroy
        client = Client.find(params[:id])
        client.destroy
        RegistrarEventoAuditoriaJob.perform_later(servicio_origen: "clientes", accion: "ELIMINAR_CLIENTE", detalle: { id: client.id })
        head :no_content
      end

      private

      def client_params
        params.require(:client).permit(:name, :identification, :email, :address)
      end
    end
  end
end
