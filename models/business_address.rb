class BusinessAddress < ActiveRecord::Base
  belongs_to :business
  
  after_initialize :init
  
  def init
    self.status_type_code ||= LookupTypeCode.address_status_type.id

    self.status_item_code ||= LookupItemCode.find_by(lookup_type_code_id: self.status_type_code).id
  end
end
