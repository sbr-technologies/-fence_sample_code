module Api
  module V1
    class SuppliersController < ApplicationController
      protect_from_forgery
      ssl_exceptions
      skip_before_action :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
      load_and_authorize_resource :business
      #  load_and_authorize_resource :project, through: :business
      respond_to :json

      def index
        respond_with current_business.suppliers
      end
      
      def validate
        if current_business.employees.valid_attribute?(params[:id], params[:field], params[:value]) || params[:value].blank?
          render :json => {:success => true}
        else
          render :json => {:success => false}
        end
      end

      def update_field
        @supplier = current_business.suppliers.find(params[:id])
        if @supplier.update(supplier_params.merge(modified_by))
          render json: @supplier
        else
          render json: @supplier
        end
      end
                  
      def destroy_multiple
        if !params[:selection].empty?
          destroyed = false
          params[:selection].each do |p|
#            current_business.suppliers.destroy(p[:id]) rescue ActiveRecord::RecordNotDestroyed
            record = current_business.suppliers.find(p[:id])
            record.destroy rescue ActiveRecord::RecordNotDestroyed
            destroyed = true if record.destroyed?
          end
          if destroyed
            flash[:notice] = I18n.t('supplier.delete_selected')
          else
            flash[:error] = I18n.t('supplier.in_use_selected')
          end
          render json: {:status => true, :url => business_suppliers_path(current_business)}
        end
      end
      
      private 
    
      def supplier_params
params.require(:supplier).permit(:business_name, :last_name, :first_name, :middle_initial, :start_date, :end_date, :business_account_number, :status_item_code)
      end
    end
  end
end



