class EmployeesController < ApplicationController
  ssl_exceptions [:print_multiple]
  before_action :authenticate_user!
  before_action only: [:create, :update] { format_date_params(:employee) }
  load_and_authorize_resource :business
  load_and_authorize_resource :employee, through: :business

  def index
    @employees
  end

  def new
    @employee.addresses.build
    @employee.phones.build
  end

  def create
    if @employee.save
      if @employee.email_address1.present?
        flash[:notice] = I18n.t('employee.created_with_email', email: @employee.email_address1)
      else
        flash[:notice] = I18n.t('employee.created_without_email', email: @employee.email_address1)
      end
      redirect_to business_employees_path(@business)
    else
      render 'new'
    end
  end
  
  def unique_employee_number
    if current_business.employees.valid_attribute?(params[:employee][:id],'employee_number', params[:employee][:employee_number]) || params[:employee][:employee_number].blank?
      render json: true
    else
      render json: false
    end
  end

  def update
#    previous_email = @employee.unconfirmed_email
    if @employee.update(employee_params)
#      if previous_email != @employee.unconfirmed_email
#        flash[:notice] = I18n.t('devise.registrations.update_needs_confirmation')
#      else
        flash[:notice] = I18n.t('employee.update')
#      end
      redirect_to business_employees_path(@business)
    else
      render 'edit'
    end
  end

  def destroy
    @employee.destroy
    flash[:notice] = I18n.t('employee.delete')
    redirect_to business_employees_path(@business)
  end
  
  def print_multiple
    employees = JSON.parse(params[:employee_ids]);
    @employees = current_business.employees.find(employees)
    html = render_to_string(layout: false, :template => 'employees/print_multiple.html.haml')
#    kit = PDFKit.new(html, :header => name_business_pdf_index_url(@business))
    kit = PDFKit.new(html)
    kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/print_multiple.css"
    send_data(kit.to_pdf, filename: "employees.pdf", type: 'application/pdf')
  end

  private

  def employee_params
    attr =[:first_name, :last_name, :middle_initial, :employee_number, :ssn, :hourly_rate, :start_date, :end_date, :gross_salary, :taxes, :net_salary, :end_reason_notes, :end_reason_item_code, :status_item_code, :employee_item_code, :id].push(address_attr).push(phone_attr)
#    if current_employee.id == params[:employee][:id]
#      params[:employee][:need_login] = true
#    end
    params.require(:employee).permit(attr)
  end
end
