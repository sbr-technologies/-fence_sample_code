module Api
  module V1
    class CustomersController < ApplicationController
      protect_from_forgery
      ssl_exceptions
      skip_before_action :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
      load_and_authorize_resource :business
      #  load_and_authorize_resource :project, through: :business
      respond_to :json

      def index
        respond_with current_business.customers
      end
      
      def index_names_only
        respond_with current_business.customers.collect{ |c| {:name => c.get_name, :id => c.id} }
      end

      def create
        o = current_business
        @customer = o.customers.create(customer_params)
        @customer.addresses.new(addresses_params)
        @customer.save
        respond_with :api, :v1, @customer
	   
      end
      
      def end_reason_items
        respond_with current_business.lookup_item_codes.where({:lookup_type_code_id => Customer.end_reason_type}).select(:id, :description)
      end
      
      def validate_business
        if current_business.customers.valid_attribute?(params['id'], 'business_name', params[:business_name]) || params[:business_name].blank?
          render :json => {:success => true}
        else
          render :json => {:success => false}
        end
      end
      
      def update_field
        @customer = current_business.customers.find(params[:id])
        if @customer.update(customer_params.merge(modified_by))
          render json: @customer
        else
          render json: current_business.customers.find(params[:id])
        end
      end
      
      def destroy_multiple
        if !params[:selection].empty?
          destroyed = false
          params[:selection].each do |p|
#            current_business.customers.destroy(p[:id]) rescue ActiveRecord::RecordNotDestroyed
            record = current_business.customers.find(p[:id])
            record.destroy rescue ActiveRecord::RecordNotDestroyed
            destroyed = true if record.destroyed?
          end
          if destroyed
            flash[:notice] = I18n.t('customer.delete_selected')
          else
            flash[:error] = I18n.t('customer.in_use_selected')
          end
          render json: {:status => true, :url => business_customers_path(current_business)}
        end
      end

      private   
    
      def customer_params
        attr = [:name, :margin_percent, :last_name, :first_name, :middle_name, :start_date, :end_date, :business_ac, :end_reason_note, :end_reason_id, :status_item_code]
        params.require(:customer).permit(attr)
      end
    
      def addresses_params
        params.require(:addresses_attributes).permit([:address, :state, :city, :country, :zip, :is_primary, :id, :_destroy])
      end
    end
  end
end

