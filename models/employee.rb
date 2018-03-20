class Employee < ActiveRecord::Base
  STATUS = 'Employee Status'
  END_REASON = 'Employee End Reason'
  TYPE = 'Employee Type'
  belongs_to :business
  
  has_one :user
  has_many :addresses, :class_name => 'EmployeeAddress', dependent: :destroy
  has_many :phones, :class_name => 'EmployeePhone', dependent: :destroy
  
  validates :last_name, :first_name, :business, presence: true, on: :update
  validates :employee_number, numericality: { greater_than: 0, less_than_or_equal_to: 999999999 }, :allow_nil => true, uniqueness: { :scope => :business_id }
  validates_length_of :middle_initial, maximum: 1, allow_blank: true
  validates :hourly_rate, numericality: true, if: Proc.new{|e| e.hourly_rate.present?}
  validates :gross_salary, numericality: true, if: Proc.new{|e| e.gross_salary.present?}
  validates :taxes, numericality: true, if: Proc.new{|e| e.taxes.present?}
  validates :net_salary, numericality: true, if: Proc.new{|e| e.net_salary.present?}
  validates_with EndAfterStartValidator
  
  accepts_nested_attributes_for :addresses, :phones, allow_destroy: true
  
  after_initialize :init
  before_destroy :can_destroy?
  
  def self.status_type
    LookupTypeCode.find_by_description(STATUS)
  end
  
  def self.end_reason_type
    LookupTypeCode.find_by_description(END_REASON)
  end
  
  def self.employee_type
    LookupTypeCode.find_by_description(TYPE)
  end
  
  def init
    self.status_type_code ||= self.class.status_type.id
    self.end_reason_type_code ||= self.class.end_reason_type.id
    self.employee_type_code ||= self.class.employee_type.id
  end
  
  def name
    [last_name, middle_initial, first_name].select(&:present?).join(' ').titleize
  end
  
  def status
    LookupItemCode.find(self.status_item_code).description unless self.status_item_code.nil?
  end
  
  def can_destroy?
    !is_enterprise_admin?
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
  
  def is_enterprise_admin?
    self.user.present? && self.user.role && self.user.role.level == Role::ROLE_LEVELS[:enterprise_admin]
  end
end
