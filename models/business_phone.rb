class BusinessPhone < ActiveRecord::Base
  belongs_to :business
  
  after_initialize :init
  
  def init
    self.status_type_code ||= LookupTypeCode.phone_status_type.id
    self.phone_type_code ||= LookupTypeCode.phone_type_code.id
    
    self.status_item_code ||= LookupItemCode.find_by(lookup_type_code_id: self.status_type_code).id
    self.phone_item_code ||= LookupItemCode.find_by(lookup_type_code_id: self.phone_type_code).id
  end
end
