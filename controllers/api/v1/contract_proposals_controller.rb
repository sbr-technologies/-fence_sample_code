module Api
  module V1
    class ContractProposalsController < ApplicationController
      protect_from_forgery
      ssl_exceptions
      skip_before_action :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
      load_and_authorize_resource :business
      #      load_and_authorize_resource :contract, through: :business
      respond_to :json

      def index
        @contract_proposals = current_business.contract_proposals
        @contract_proposals = @contract_proposals.customer(params[:customer_id]) if params[:customer_id].present?
        @contract_proposals = @contract_proposals.project_group(params[:project_group_id]) if params[:project_group_id].present?
        @contract_proposals = @contract_proposals.start_date(params[:start_date]) if params[:start_date].present?
        @contract_proposals = @contract_proposals.completion_date(params[:completion_date]) if params[:completion_date].present?

        respond_with @contract_proposals
      end

      def create
        customer_id = params[:contract][:customer_id]
        ActiveRecord::Base.transaction do
          if !params['customer_attrubutes'].nil?
            @cust = current_business.customers.new(customer_params.merge(created_by))
            @cust.addresses.first.assign_attributes({:business_id => current_business.id, :created_by => current_user.id, :modified_by => current_user.id})
            @cust.phones.first.assign_attributes({:business_id => current_business.id, :created_by => current_user.id, :modified_by => current_user.id})
            @cust.contact_persons.first.assign_attributes({:business_id => current_business.id, :created_by => current_user.id, :modified_by => current_user.id})
            if !@cust.save
              render json: @cust.errors
              return
            end
            customer_id = @cust.id
          end
          @contract_proposal = current_business.contract_proposals.new(contract_params.merge(created_by).merge({customer_id: customer_id, prepared_by: current_user.id}))
          
          unless params['project_groups_attributes'].nil?
            params['project_groups_attributes'].each do |p|
              proj = @contract_proposal.cp_project_groups.build(cp_pg_description: p['cp_pg_description'],cp_pg_long_description: p['cp_pg_long_description'], business_id: current_business.id, project_group_id: p['project_group_id'])
                unless p[:pg_products].nil?
                  p[:pg_products].each do |pp|
                    proj.cp_pg_products.build(business_id: current_business.id, cp_project_group_id: proj.id, project_group_id: proj.project_group_id, product_id: pp['product_id'], quantity: pp['quantity'], retail_price: pp[:retail_price], labor_hours: pp['labor_hours'], labor_cost: pp['labor_cost'], uom_item_code: pp['uom_item_code'])
                  end
                end
            end
          end

          if !@contract_proposal.save
            render json: @contract_proposal.errors
            return
          end
        end
        flash[:notice] = I18n.t('contract_proposal.notice')
        render :json => {:success => true, :redirect_url => business_contract_proposals_path(current_business)}
      end
      
      def edit
        @contract_proposal = current_business.contract_proposals.find(params[:id])
        render :json => {:contract => @contract_proposal.attributes.merge({:status => @contract_proposal.status, :customer => @contract_proposal.customer.get_name, :margin_percent => @contract_proposal.customer.margin_percent, :creator => @contract_proposal.creator.name, :updator => @contract_proposal.updator.name}), :cp_project_groups => @contract_proposal.cp_project_groups.collect {
            |p| {
              :id => p.id, :project_group_id => p.project_group_id, :project_group_name => p.project_group.project_group_name, :cp_pg_description => p.cp_pg_description, :cp_pg_long_description => p.cp_pg_long_description, :pg_products => p.cp_pg_products.collect {
                |pp| {:id => pp.product_id, :product_id => pp.product_id, :product_name => pp.product.product_name, :quantity => pp.quantity, :uom_item_code => pp.uom_item_code, :retail_price => pp.retail_price.to_f, :cost_price => pp.product.cost_price, :product_retail_price => pp.product.retail_price, :labor_hours => pp.labor_hours, :labor_cost => pp.labor_cost.to_f} 
              }} 
          }}
      end
      
      def update
        @contract = current_business.contract_proposals.find(params[:id])
        ActiveRecord::Base.transaction do
          if params['customer_attrubutes'].nil?
            customer_id = params[:contract][:customer_id]
          else
            @cust = current_business.customers.new(customer_params.merge(created_by))
            @cust.addresses.first.assign_attributes({:business_id => current_business.id, :created_by => current_user.id, :modified_by => current_user.id})
            @cust.phones.first.assign_attributes({:business_id => current_business.id, :created_by => current_user.id, :modified_by => current_user.id})
            @cust.contact_persons.first.assign_attributes({:business_id => current_business.id, :created_by => current_user.id, :modified_by => current_user.id})
            if !@cust.save
              render json: @cust.errors
              return
            end
            customer_id = @cust.id
          end
          CpProjectGroup.where("contract_proposal_id = (?)", @contract.id).destroy_all
          if !params['project_groups_attributes'].nil?
            params['project_groups_attributes'].each do |p|
                proj_exists = @contract.cp_project_groups.build(cp_pg_description: p['cp_pg_description'], cp_pg_long_description: p['cp_pg_long_description'],  business_id: current_business.id, project_group_id: p['project_group_id'])
                unless p[:pg_products].nil?
                  p[:pg_products].each do |pp|
                    proj_exists.cp_pg_products.build(business_id: current_business.id, cp_project_group_id: proj_exists.id, project_group_id: proj_exists.project_group_id, product_id: pp['product_id'], quantity: pp['quantity'], retail_price: pp['retail_price'], labor_hours: pp['labor_hours'], labor_cost: pp['labor_cost'], uom_item_code: pp['uom_item_code'])
                  end
                end
            end
          end

          if !@contract.update(contract_params.merge(modified_by).merge({:customer_id => customer_id}))
            render :json => {:success => false, :errors => @contract.errors}
            return
          end
        end
          flash[:notice] = I18n.t('contract_proposal.update')
          render :json => {:success => true, :redirect_url => business_contract_proposals_path(current_business)}
      end
      
      
      def update_field
        @contract_proposal = current_business.contract_proposals.find(params[:id])
        if @contract_proposal.update(contract_params.merge(modified_by))
          render json: @contract_proposal
        else
          render json: current_business.contract_proposals.find(params[:id])
        end
      end
      
      def validate_job_number
        if current_business.contract_proposals.valid_attribute?(params['id'], 'job_number', params[:job_number]) || params[:job_number].blank?
          render :json => {:success => true}
        else
          render :json => {:success => false}
        end
      end

      def destroy_multiple
        #  render :text => params.inspect
        if !params[:selection].empty?
          params[:selection].each do |p|
            ContractProposal.destroy(p['id'])
          end
          flash[:notice] = I18n.t('contract_proposal.delete_selected')
          render json: {:status => true, :url => business_contract_proposals_path(current_business)}
        end
      end
      
      def status_items
        @status_items = current_business.lookup_item_codes.where({:lookup_type_code_id => ContractProposal.status_type}).select(:id, :description)
        respond_with @status_items
      end

      private
      def contract_params
#        params.require(:contract).permit(:customer_id, :job_number, :proposal_date, :start_date, :completion_date, :status, :proposal_date, :approx_start_date, :approx_completion_date, :proposal_terms, :addn_provisions, :payment_terms, :advance, :amt, :signed_date, :middle_name, :first_name, :last_name, :start_date)
        attrs = [:job_number, :job_description, :job_long_description, :proposal_date, :start_date, :completion_date, :status_item_code, :approx_start_date, :approx_completion_date, :cp_proposal_terms_item_code, :cp_proposal_terms, :cp_payment_terms_item_code, :cp_payment_terms, :advance_payment, :signed_date, :signed_by_lastname, :signed_by_firstname, :signed_by_mi, :start_date, :job_status_notes]
#        attrs << :customer_id
        params.require(:contract).permit(attrs)
      end
      
#      def project_params
#        params.require(:projects_attributes).permit(:copy_project_id, :of_type, :name, :description, :long_description, :project_category_id, :business_id)
#      end
      
      def customer_params
        attr = [:business_name, :margin_percent, :last_name, :first_name, :middle_initial, :start_date, :end_date, :business_account_nmbr, :end_reason_item_code, :end_reason_notes, :status_item_code]
        attr.push(address_attr).push(phone_attr).push(contact_person_attr)
        params.require(:customer_attrubutes).permit(attr)
      end
    
#      def addresses_params
#        params.require(:customer_attrubutes).permit(:addresses_attributes => [:address, :state, :city, :country, :zip])
#      end
      
    end
  end
end

