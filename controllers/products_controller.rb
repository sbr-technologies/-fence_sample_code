class ProductsController < ApplicationController
  ssl_exceptions [:print_multiple]
  before_action :authenticate_user!
  load_and_authorize_resource :business, except: :dashboard
  load_and_authorize_resource :product, through: :business, except: :dashboard
  before_action :load_supplier_and_manufacturer, except:  [:index, :destroy, :dashboard]

  def index
    @products
    respond_to do |format|
      format.html
      format.json { render json: ProductsDatatable.new(view_context, @products) }
    end
  end

#  def new
#    @product.product_rates.build
#  end

  def create
    if @product.save
      flash[:notice] = I18n.t('product.notice')
      redirect_to business_products_path(@business)
    else
      render 'new'
    end
  end

  def update
    if @product.update(product_params)
      flash[:notice] = I18n.t('product.update')
      redirect_to business_products_path(@business)
    else
      render 'edit'
    end
  end

  def destroy
    # TODO: Check for dependent destroy of project_products
    @product.destroy
    flash[:notice] = I18n.t('product.delete')
    redirect_to business_products_path(@business)
  end

  def dashboard
    @business = current_business
  end
  
  def print_multiple
    products = JSON.parse(params[:product_ids]);
    @products = current_business.products.find(products)
    html = render_to_string(layout: false, :template => 'products/print_multiple.html.haml')
#    kit = PDFKit.new(html, :header => name_business_pdf_index_url(@business))
    kit = PDFKit.new(html)
    kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/print_multiple.css"
    send_data(kit.to_pdf, filename: "products.pdf", type: 'application/pdf')
  end
  
  def unique_product_sku
    if current_business.products.valid_attribute?(params[:product][:id],'product_sku', params[:product][:product_sku]) || params[:product][:product_sku].blank?
      render json: true
    else
      render json: false
    end
  end

  private

  def product_params
    params.require(:product).permit(:product_sku, :product_name, :category_item_code, :uom_item_code, :preferred_supplier_id, :manufacturer_id, :description, :long_description, :cost_price, :retail_price, :status_item_code)
  end

  def load_supplier_and_manufacturer
    @suppliers = @business.suppliers
    @manufacturers = @business.manufacturers
    if @suppliers.empty? or @manufacturers.empty?
      flash.now[:notice] = I18n.t('product.prerequisite_msg')
    end
  end
end
