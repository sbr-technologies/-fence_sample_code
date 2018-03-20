class ApplicationController < ActionController::Base
  include ::SslRequirement
#  include Userstamp
  protect_from_forgery with: :exception
  helper_method :current_business, :amount_format, :current_employee

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def after_sign_in_path_for(resource)
    business_products_path(current_business)
  end

  def default_serializer_options  
    {root: false}  
  end  

  def current_employee
    @current_employee ||= Employee.find(current_user.employee_id)
  end

  def current_business
    @current_business ||= current_employee.business
  end

  def amount_format(amt)
    if amt.is_a? Money
      money_without_cents amt
    else
      amt.to_f/100
    end
  end
  
  def created_by
    {created_by: current_user.id, modified_by: current_user.id}
  end
  
  def modified_by
    {modified_by: current_user.id}
  end

  def from_amount_format(amt)
    amt.to_f*100
  end

  def address_business
    {:address_attributes => [:line_1, :line_2, :state, :city, :zip, :zip_suffix_code, :is_primary, :id]}
  end

  def contact_attrs
    {:contacts_attributes => [:first_name, :last_name, :middle_name, :is_primary, :id, :_destroy]}
  end

  def address_attr
    {:addresses_attributes => [:line_1, :line_2, :state, :city, :zip, :zip_suffix_code, :is_primary, :id, :_destroy]}
  end

  def contact_person_attr
    {:contact_persons_attributes => [:last_name, :first_name, :middle_initial, :job_title, :department, :contact_notes, :email_address1, :email_address2, :email_address3, :phone_number1, :phone_number2, :phone_number3, :phone_ext1, :phone_ext2, :phone_ext3, :id, :_destroy]}
  end
  
  def phone_attr
    {:phones_attributes => [:phone_number, :is_primary, :id, :_destroy, :phone_number_ext, :phone_item_code]}
  end

  def business_phone_attr
    {:business_phones_attributes => [:phone_number, :is_primary, :id, :_destroy, :phone_number_ext]}
  end

  def employee_attr
    {:employee_attributes => [:first_name, :last_name, :middle_initial, :employee_number, :ssn, :hourly_rate, :start_date, :end_date, :gross_salary, :taxes, :net_salary, :end_reason_notes, :end_reason_item_code, :id]}
  end

  def format_date_params(type, sub_type=nil)
    param = sub_type.nil? ? params[type] : params[type][sub_type]
    param.tap do |attrs|
      attrs[:start_date] = Date.strptime(attrs[:start_date], '%m/%d/%Y')  if attrs[:start_date].present?
      attrs[:end_date] = Date.strptime(attrs[:end_date], '%m/%d/%Y')  if attrs[:end_date].present?
      if attrs[:proposal_date].present?
        attrs[:proposal_date] = Date.strptime(attrs[:proposal_date], '%m/%d/%Y')  
        attrs[:completion_date] = Date.strptime(attrs[:completion_date], '%m/%d/%Y') if attrs[:completion_date].present?
        attrs[:signed_date] = Date.strptime(attrs[:signed_date], '%m/%d/%Y')  if attrs[:signed_date].present? 
      end
    end
  end
end
