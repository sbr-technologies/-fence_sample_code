module Api
  module V1
    class EmployeesController < ApplicationController
      protect_from_forgery
      ssl_exceptions
      skip_before_action :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
      load_and_authorize_resource :business
      respond_to :json
      
      def index
        respond_with current_business.employees
      end
      
      def validate
        if current_business.employees.valid_attribute?(params[:id], params[:field], params[:value]) || params[:value].blank?
          render :json => {:success => true}
        else
          render :json => {:success => false}
        end
      end
      
      def update_field
        @employee = current_business.employees.find(params[:id])
        if @employee.update(employee_params.merge(modified_by))
          render json: @employee
        else
          render json: current_business.employees.find(params[:id])
        end
      end
                  
      def destroy_multiple
        if !params[:selection].empty?
          destroyed = false
          params[:selection].each do |p|
#            current_business.employees.destroy(p[:id]) rescue ActiveRecord::RecordNotDestroyed
            record = current_business.employees.find(p[:id])
            record.destroy rescue ActiveRecord::RecordNotDestroyed
            destroyed = true if record.destroyed?
          end
          if destroyed
            flash[:notice] = I18n.t('employee.delete_selected')
          else
            flash[:error] = I18n.t('employee.in_use_selected')
          end
          render json: {:status => true, :url => business_employees_path(current_business)}
        end
      end
      
      private
      
      def employee_params
        attr = [:employee_number, :first_name, :last_name, :middle_initial]
        params.require(:employee).permit(attr)
      end
    end
  end
end

