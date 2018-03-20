class ProjectsController < ApplicationController
  ssl_exceptions [:print]
	before_action :authenticate_user!
  load_and_authorize_resource :organization
  load_and_authorize_resource :project, through: :organization
  before_action :load_products, except: [:index, :destroy, :print, :print_multiple]

  def index
    @projects
    respond_to do |format|
      format.html
      format.json { render json: ProjectsDatatable.new(view_context, @projects) }
    end
  end

  def create
    if @project.save
      flash[:notice] = I18n.t('project.notice')
      redirect_to organization_projects_path(@organization)
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
      redirect_to organization_projects_path(@organization)
    else
      render 'edit'
    end
  end

  def destroy
    @project.destroy
    flash[:notice] = I18n.t('project.delete')
    redirect_to organization_projects_path(@organization)
  end

  def print
    html = render_to_string(layout: false, :template => 'projects/print.html.haml')
    kit = PDFKit.new(html)
    kit.stylesheets << "#{Rails.root}/vendor/assets/stylesheets/projects.css"
    send_data(kit.to_pdf, filename: "#{@project.name}.pdf", type: 'application/pdf')
  end
  
  def print_multiple
    projects = JSON.parse(params[:project_ids]);
    @projects = Project.find(projects)
#    render :text => @projects.inspect
    html = render_to_string(layout: false, :template => 'projects/print_multiple.html.haml')
#    kit = PDFKit.new(html, :header => name_organization_pdf_index_url(@organization))
    kit = PDFKit.new(html, :header_left => @organization.business_name, :header_right => @organization.email_address1, :footer_center => "Page [page] of [toPage]")
    kit.stylesheets << "#{Rails.root}/vendor/assets/stylesheets/projects.css"
    send_data(kit.to_pdf, filename: "projects.pdf", type: 'application/pdf')
  end

  private

  def project_params
    params.require(:project).permit(:name, :project_category_id, :description, :long_description, :status, :project_products_attributes => [:id, :product_id, :name, :quantity, :labor_hour, :labor, :status, :_destroy, :unit_of_measurement_id, :retail_price])
  end
  
  def load_products
    @products = @organization.products.active.includes(:product_category).group_by{|p| p.product_category.description }
    if @products.empty?
      flash.now[:notice] = I18n.t('project.prerequisite_msg')
    end
  end
end
