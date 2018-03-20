class ProjectProductsController < ApplicationController
  ssl_exceptions

  def index
    @project_products = ProjectProduct.all
  end
  
  def new
    @project_product = ProjectProduct.new
  end
end
