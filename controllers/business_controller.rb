class BusinessController < ApplicationController
  ssl_exceptions
  before_action :authenticate_user!
  load_and_authorize_resource :business

  def edit
    @business.address || @business.build_address
    @business.phones || @business.phones.build
  end

  def update
    if @business.update(business_params)
      if saving_proposal_term?
        flash[:notice] = I18n.t('business.proposal_update')
        redirect_to lookup_values_business_path(@business)
      else
        flash[:notice] = I18n.t('business.update')
        redirect_to edit_business_path(@business)
      end
    else
      render 'edit'
    end
  end

  def lookup_values
    if request.patch?
      @business.update(lookup_params)
      @lookup_items = @business.lookup_item_codes.where(:lookup_type_code_id => params[:lookup_type]).as_json(only: [:id, :description, :long_description], methods: [:can_destroy?])
      render json: @lookup_items
    end
  end

  private

  def business_params
    attrs = [:business_name, :license_number, :last_name, :first_name, :middle_initial, :logo, :bond_status].push(phone_attr).push(address_business).push(contact_person_attr).push({:default_proposal_term_attributes => [:proposal_terms, :payment_terms, :additional_provision]})
    params.require(:business).permit(attrs)
  end

  def lookup_params
    permitted_paramater = [:id, :lookup_type_code_id, :description, :long_description]
    params.require(:business).permit(lookup_item_codes_attributes: permitted_paramater)
  end

  def saving_proposal_term?
    params[:business][:default_proposal_term_attributes].present?
  end
end
