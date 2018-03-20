class ProjectGroupSerializer < ActiveModel::Serializer
  attributes :id, :project_group_name, :category, :category_item_code, :project_group_description, :project_group_long_description, :status_item_code, :status, :can_destroy?, :product_count
end