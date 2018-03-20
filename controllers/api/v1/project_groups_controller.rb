module Api
  module V1
    class ProjectGroupsController < ApplicationController
      protect_from_forgery
      ssl_exceptions
      skip_before_action :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
      load_and_authorize_resource :business
      #  load_and_authorize_resource :project, through: :business
      respond_to :json
      
      def index
        respond_with current_business.project_groups
      end
      
      def pg_products
        render :json => current_business.project_groups.collect{ |pg| {:id => pg.id, :project_group_id => pg.id, :project_category_id => pg.category_item_code, :project_group_name => pg.project_group_name, :project_group_description => pg.project_group_description, :cp_pg_description => pg.project_group_description, :cp_pg_long_description => pg.project_group_long_description, :pg_products => pg.pg_products.collect{|pgp|{:product_id => pgp.product_id, :product_name => pgp.product.product_name, :product_retail_price => pgp.product.retail_price.to_f, :cost_price => pgp.product.cost_price.to_f, :category_item_code => pgp.product.category_item_code, :quantity => pgp.quantity, :uom_item_code => pgp.uom_item_code, :labor_hours => pgp.labor_hours, :labor_cost => pgp.labor_cost.to_f}}}}
      end
      
      def create
        @project_group = current_business.project_groups.new(project_params.merge(created_by))
        if !params['selection'].nil?
          params['selection'].each do |p|
            @project_group.pg_products.build(business_id: current_business.id, quantity: p['quantity'], product_id: p['product_id'], uom_item_code: p['uom_item_code'], labor_hours: p['labor_hours'], labor_cost: p['labor_cost'])
          end
        end
        if !@project_group.save
            render :json => @project_group.errors
            return
        end
        flash[:notice] = I18n.t('project_group.notice')
        render :json => {:redirect_url => business_project_groups_path(current_business)}
      end
      
      def edit
        @project_group = ProjectGroup.find(params[:id])
        respond_with @project_group
      end
      
      def update_field
        @project_group = current_business.project_groups.find(params[:id])
        if @project_group.update(project_params.merge(modified_by))
          render json: @project_group
        else
          render json: current_business.project_groups.find(params[:id])
        end
      end
      
      def update
        @project_group = current_business.project_groups.find(params[:id])
        ActiveRecord::Base.transaction do
          PgProduct.where("project_group_id = (?)", @project_group.id).destroy_all
          if !params['selection'].nil?
            params['selection'].each do |p|
              @project_group.pg_products.build(business_id: current_business.id, quantity: p['quantity'], product_id: p['product_id'], uom_item_code: p['uom_item_code'], labor_hours: p['labor_hours'], labor_cost: p['labor_cost'])
            end
          end
          if !@project_group.update(project_params.merge(modified_by))
              render :json => @project_group.errors
              return
          end
        end
        flash[:notice] = I18n.t('project_group.update')
        render :json => {:redirect_url => business_project_groups_path(current_business)}
      end
      
      def destroy_multiple
        if !params[:selection].empty?
          destroyed = false
          params[:selection].each do |p|
#            current_business.project_groups.destroy(p['id']) rescue ActiveRecord::RecordNotDestroyed
            record = current_business.project_groups.find(p[:id])
            record.destroy rescue ActiveRecord::RecordNotDestroyed
            destroyed = true if record.destroyed?
          end
          if destroyed
            flash[:notice] = I18n.t('project_group.delete_selected')
          else
            flash[:error] = I18n.t('project_group.in_use_selected')
          end
          render json: {:status => true, :url => business_project_groups_path(current_business)}
        end
      end
      
      
      def category_items
        @categories = current_business.lookup_item_codes.where({:lookup_type_code_id => ProjectGroup.category_type}).select(:id, :description)
        respond_with @categories
      end
      
      def status_items
        @status_items = current_business.lookup_item_codes.where({:lookup_type_code_id => ProjectGroup.status_type}).select(:id, :description)
        respond_with @status_items
      end
      
      def validate_name
        if current_business.project_groups.valid_attribute?(params['id'], 'project_group_name', params[:project_group_name]) || params[:project_group_name].blank?
          render :json => {:success => true}
        else
          render :json => {:success => false}
        end
      end
      
      private
      def project_params
        params.require(:project_group).permit(:project_group_name, :category_item_code, :project_group_description, :project_group_long_description, :status_item_code)
      end
      
    end
  end
end

