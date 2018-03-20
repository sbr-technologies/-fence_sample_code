module ProductsHelper
  def product_category_items
    @business.lookup_item_codes.where({:lookup_type_code_id => Product.category_type}).select(:id, :description).collect{|i| [i.description, i.id]}
  end
  
  def uom_items
    @business.lookup_item_codes.where({:lookup_type_code_id => Product.uom_type}).select(:id, :description).collect{|i| [i.description, i.id]}
  end
  
  def product_status_items
    @business.lookup_item_codes.where({:lookup_type_code_id => Product.status_type}).collect{|i| [i.description, i.id]}
  end
end
