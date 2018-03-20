module SuppliersHelper

  def supplier_status_items
    @business.lookup_item_codes.where({:lookup_type_code_id => Supplier.status_type}).collect{|i| [i.description, i.id]}
  end

  def supplier_end_reason_items
    @business.lookup_item_codes.where({:lookup_type_code_id => Supplier.end_reason_type}).collect{|i| [i.description, i.id]}
  end

end