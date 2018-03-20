class ProductSerializer < ActiveModel::Serializer
  attributes :id, :product_id, :product_name, :product_sku, :category, :category_item_code, :description, :uom_item_code, :unit_of_measure, :retail_price, :product_retail_price,  :cost_price, :status_item_code, :status, :can_destroy?
  
  def category
    LookupItemCode.find(object.category_item_code).description
  end
  
  def product_id
    object.id
  end
  
  def product_retail_price
    object.retail_price
  end
  
end
