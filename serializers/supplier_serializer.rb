class SupplierSerializer < ActiveModel::Serializer
  attributes :id, :business_name, :name, :last_name, :first_name, :middle_initial, :start_date, :end_date, :business_account_number, :status_item_code, :status, :can_destroy?
end