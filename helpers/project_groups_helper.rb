module ProjectGroupsHelper
  def project_group_category_items
    @business.lookup_item_codes.where({:lookup_type_code_id => ProjectGroup.category_type}).collect{|i| [i.description, i.id]}
  end
  
  def project_group_status_items
    @business.lookup_item_codes.where({:lookup_type_code_id => ProjectGroup.status_type}).collect{|i| [i.description, i.id]}
  end
end
