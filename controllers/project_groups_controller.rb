class ProjectGroupsController < ApplicationController
  ssl_exceptions [:print]
	before_action :authenticate_user!
  load_and_authorize_resource :business
  load_and_authorize_resource :project_group, through: :business

  def create
    if @project.save
      flash[:notice] = I18n.t('project.notice')
      redirect_to business_projects_path(@business)
    else
      render 'new'
    end
  end
  
#  def edit
#    render 'edit'
#  end

  def update
    if @project.update(project_params)
      flash[:notice] = I18n.t('project.update')
      redirect_to business_projects_path(@business)
    else
      render 'edit'
    end
  end

  def destroy
    @project.destroy
    flash[:notice] = I18n.t('project.delete')
    redirect_to business_projects_path(@business)
  end
#
#  def print
#    html = render_to_string(layout: false, :template => 'projects/print.html.haml')
#    kit = PDFKit.new(html)
#    kit.stylesheets << "#{Rails.root}/vendor/assets/stylesheets/projects.css"
#    send_data(kit.to_pdf, filename: "#{@project.name}.pdf", type: 'application/pdf')
#  end
  
  def print_multiple
    projects = JSON.parse(params[:project_ids]);
    @project_groups = current_business.project_groups.find(projects)
    
    @address = @business.address
    @phone = @business.phones.where(is_primary: true)
    if @phone.present?
      @phone = @phone.first
    else
      @phone = @business.phones.first
    end
    @contact = @business.contact_persons.first
#    render :text => @projects.inspect
    html = render_to_string(layout: false, :template => 'project_groups/print_multiple.html.haml')
#    kit = PDFKit.new(html, :header => name_business_pdf_index_url(@business))
    kit = PDFKit.new(html, :footer_center => "Page [page] of [toPage]")
    kit.stylesheets << "#{Rails.root}/vendor/assets/stylesheets/projects.css"
    kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/print_multiple.css"
    send_data(kit.to_pdf, filename: "project-groups.pdf", type: 'application/pdf')
  end

  private

  def project_params
    params.require(:project).permit(:name, :project_category_id, :description, :long_description, :status, :project_products_attributes => [:id, :product_id, :name, :quantity, :labor_hour, :labor, :status, :_destroy, :unit_of_measurement_id, :retail_price])
  end
  
#  def load_products
#    @products = @business.products.active.includes(:product_category).group_by{|p| p.product_category.description }
#    if @products.empty?
#      flash.now[:notice] = I18n.t('project.prerequisite_msg')
#    end
#  end
end
