class Manufacturer < ActiveRecord::Base
  STATUS = 'Manufacturer Status'
  END_REASON = 'Manufacturer End Reason'
  
  belongs_to :business
  has_many :products

  has_many :addresses, :class_name => 'ManufacturerAddress', dependent: :destroy
  has_many :phones, :class_name => 'ManufacturerPhone', dependent: :destroy
  has_many :contact_persons, :class_name => 'ManufacturerContactPerson', dependent: :destroy
  
  validates :status_item_code, presence: true
  validates :first_name, :last_name, presence: true, if: Proc.new{|c| c.business_name.blank?}
  validates :business_name, presence: true, uniqueness: {scope: :business_id}, if: Proc.new{|c| c.first_name.blank? and c.last_name.blank? }
#  validates :business_account_number, uniqueness: { scope: :business_id, :case_sensitive => false }
  validates_with EndAfterStartValidator

  accepts_nested_attributes_for :addresses, :phones, :contact_persons, allow_destroy: true

  after_initialize :init
  before_destroy :check_if_associated_with_products
  def self.status_type
    LookupTypeCode.find_by_description(STATUS)
  end
  
  def self.end_reason_type
    LookupTypeCode.find_by_description(END_REASON)
  end
  
  def init
    self.status_type_code ||= self.class.status_type.id
    self.end_reason_type_code ||= self.class.end_reason_type.id
  end
  
  def name
    business_name.present? ? business_name : "#{last_name} #{first_name} #{middle_initial}".strip
  end
  
    
  def status
    LookupItemCode.find(self.status_item_code).description unless self.status_item_code.nil?
  end
  
  def can_destroy?
    products.present?
  end
  
  def self.valid_attribute?(id, attr, value)
    if id.blank?
      mock = self.new(attr => value)
    else
      mock = self.find(id)
      mock.assign_attributes(attr => value)
    end
    if mock.valid?
      true
    else
      mock.errors[attr].blank?
    end
  end
  
  private
  
  def check_if_associated_with_products
    if can_destroy?
      errors.add(:base, I18n.t('manufacturer.errors.can_destroy'))
      return false
    end
  end
  
#Bart commented out 2-6-16
#  validate :validate_single_primary
#
#  def validate_single_primary
#    validate_single_primary_in_memory_for(phones)
#    validate_single_primary_in_memory_for(addresses)
#    validate_single_primary_in_memory_for(contacts)
#  end

end
