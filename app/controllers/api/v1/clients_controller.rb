module Api
  module V1
    class ClientsController < ApplicationController
      def index
        clients = Client.all
        render json: clients
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
        client = Client.new(client_params)
        if client.save
          RegistrarEventoAuditoriaJob.perform_later(servicio_origen: "clientes", accion: "CREAR_CLIENTE", detalle: client.as_json)
          render json: client, status: :created
        else
          RegistrarEventoAuditoriaJob.perform_later(servicio_origen: "clientes", accion: "ERROR_CREAR_CLIENTE", detalle: client.errors)
          render json: client.errors, status: :unprocessable_entity
        end
      end

      private

      def client_params
        params.require(:client).permit(:name, :identification, :email, :address)
      end
    end
  end
end
