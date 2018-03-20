module Api
  module V1
    class ProductsController < ApplicationController
      protect_from_forgery
      ssl_exceptions
      skip_before_action :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
      load_and_authorize_resource :business
      #  load_and_authorize_resource :project, through: :business
      respond_to :json
      
      def index
        respond_with current_business.products
      end
      
      def category_items
        @categories = current_business.lookup_item_codes.where({:lookup_type_code_id => Product.category_type}).select(:id, :description)
        respond_with @categories
      end
      
      def status_items
        @status_items = current_business.lookup_item_codes.where({:lookup_type_code_id => Product.status_type}).select(:id, :description)
        respond_with @status_items
      end
      
      def uom_items
        @status_items = current_business.lookup_item_codes.where({:lookup_type_code_id => Product.uom_type}).select(:id, :description)
        respond_with @status_items
      end
      
      def validate
        if current_business.products.valid_attribute?(params[:id], params[:field], params[:value]) || params[:value].blank?
          render :json => {:success => true}
        else
          render :json => {:success => false}
        end
      end
      
      def update_field
        @product = current_business.products.find(params[:id])
        if @product.update(product_params.merge(modified_by))
          render json: @product
        else
          render json: current_business.products.find(params[:id])
        end
      end
      
      def destroy_multiple
        #  render :text => params.inspect
        
        if !params[:selection].empty?
          destroyed = false
          params[:selection].each do |p|
            record = current_business.products.find(p[:id])
            record.destroy rescue ActiveRecord::RecordNotDestroyed
            destroyed = true if record.destroyed?
          end
          if destroyed
            flash[:notice] = I18n.t('product.delete_selected')
          else
            flash[:error] = I18n.t('product.in_use_selected')
          end
          render json: {:status => true, :url => business_products_path(current_business)}
        end
      end
      
      private
      
      def product_params
        params.require(:product).permit(:product_sku, :product_name, :category_item_code, :uom_item_code, :preferred_supplier_id, :manufacturer_id, :description, :long_description, :cost_price, :retail_price, :status_item_code)
      end
    end
  end
end

