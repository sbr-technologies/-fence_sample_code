class ConfirmationsController < Devise::ConfirmationsController
  ssl_exceptions

  def update
    business = Business.find(params[:business_id])
    business.update_attributes!(business_params)
    user = User.find_by(employee_id: business.employees.first.id)
    user.confirm!
    flash[:notice] = I18n.t('devise.confirmations.confirmed')
    sign_in(user, resource)
    redirect_to business_products_path(business) 
  end

  def show
    if user.nil?
      redirect_to new_user_session_path, notice: I18n.t('errors.messages.already_confirmed')
    else
      @employee = Employee.find(user.employee_id)
      @business = @employee.business
#      if @employee.is_enterprise_admin? and !@employee.confirmed?
      if user.is_enterprise_admin? and !user.confirmed?
        @business.build_address
        @business.phones.build
        @business.contact_persons.build
      else
        user.confirm!
        flash[:notice] = I18n.t('devise.confirmations.confirmed')
        sign_in_and_redirect(User, user)
      end
    end
  end

  private

  def user
    return @user if @user
    confirmation_token = Devise.token_generator.digest(User, :confirmation_token, params['confirmation_token'])
    @user = User.find_by_confirmation_token(confirmation_token)
  end

  def business_params
    params.require(:business).permit([:business_name, :last_name, :first_name, :middle_initial, employees_attributes: [:id, :first_name, :last_name, :middle_initial]].push(address_business).push(phone_attr).push(contact_person_attr))
  end

end
