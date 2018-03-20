class Business < ActiveRecord::Base
  STATUS = 'Business Status'
  END_REASON = 'Business End Reason'
  has_attached_file :logo, styles: { medium: "300x300>", thumb: "200x150>" }, default_url: "fence.png"
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\Z/
  validates_attachment_size :logo, less_than: 1.megabytes
  
  has_many :employees
  has_many :products
  has_many :pg_products
  has_many :suppliers
  has_many :project_groups
  has_many :manufacturers
  has_many :customers
  has_many :contract_proposals
  has_many :lookup_item_codes
  
  has_one :address, :class_name => 'BusinessAddress', dependent: :destroy
  has_many :phones, :class_name => 'BusinessPhone', dependent: :destroy
  has_many :contact_persons, :class_name => 'BusinessContactPerson', dependent: :destroy
  
  after_create :create_default_item_codes

  accepts_nested_attributes_for :employees, :address, :phones, :contact_persons, :lookup_item_codes, allow_destroy: true

  validates :bond_status, length: { maximum: 25 }
  validates :business_name, presence: true, uniqueness: {case_sensitive: false}
  validate :must_have_address_and_phone , on: :update
  
  after_initialize :init
  
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

  private


  def create_default_item_codes
    type_code = LookupTypeCode.find_by(description: "Address Status")
    type_code.lookup_item_codes.create!(description: "Active", long_description: "Address is active", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Address Type")
    type_code.lookup_item_codes.create!(description: "Work", long_description: "Specifies a work address", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Business Contact Status Type")
    type_code.lookup_item_codes.create!(description: "Active", long_description: "Business Contact is active", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Business Contact Type")
    type_code.lookup_item_codes.create!(description: "Business Owner", long_description: "The Business Owner", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Business End Reason")
    type_code.lookup_item_codes.create!(description: "Business Closed", long_description: "The Business has closed down", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Business Phone Status")
    type_code.lookup_item_codes.create!(description: "Active", long_description: "An active phone number for the Business", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Business Status")
    type_code.lookup_item_codes.create!(description: "Active", long_description: "Specifies an active Business", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Contract Proposal -Proposal Payment Terms")
    type_code.lookup_item_codes.create!(description: "20/30", long_description: "If the proposal is accepted the owner agrees to pay fence landscape construction the above prices in the following manner: deposit of 20% @ signing the contract & 30% @ start of project. Balance due upon completion.  Owner / Owners Agent signature and Contractor / Agent signature constitutes a legal contract", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Contract Proposal -Proposal Terms")
    type_code.lookup_item_codes.create!(description: "Default", long_description: "FENCE Construction hereby submits this proposal for acceptance by the above names person or entity. This proposal includes all labor, materials, equipment in services to perform the following. All the services behond those specified in this proposal will be billed at an hourly labor and equipment rate plus materials.", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Contract Proposal -Additional Contract Provisions")
    type_code.lookup_item_codes.create!(description: "Default", long_description: "The following terms and provisions are incorporated in full into the proposal and when accepted by the owner the agreement by and
between the Contractor and owner shall be deemed to include these terms and provisions as the “agreement”. In case of any conflict
between these terms and provisions and any provisions of any other agreement and this agreement, the provisions set forth herein shall
prevail.
1.) This proposal is subject to revision if not accepted within thirty days as availability and costs of many materials are not constant. The
proposal is based on the conditions present in the landscape at the time of presentation.
2.) Unless otherwise stated in writing, it is the Owner’s responsibility to insure adequate water for plant materials, lawns, etc., and to
provide reasonable access to areas covered by this contract.
3.) FENCE Landscape Construction guarantees new plant material for a period of one year from the time of installation as to workmanship
and materials, provided the plants have received adequate care and water and have not died as a result of mechanical damage or an act of
God. Should a plant die due to our negligence it will be replaced free of charge with as similar a plant as is available. All guarantees are
null and void if payment or other terms of the contract have not been met.
4.) FENCE Landscape Construction shall not be liable to Owner, or any other person for loss or damage to person or property resulting
from any hazardous condition existing upon the real property.
5.) FENCE Landscape Construction shall not be held responsible or liable for any loss, damage, or delay caused by weather, strikes or any
other causes beyond our control. Contractor agrees to repair/ replace any material broken due to neglect by contractor or agents.
6.) All other work than what is specified shall be considered time plus materials and charged in addition to specified payments. Any plant
material replacement or irrigation system repair or alterations required because of vandalism, adverse weather, neglect, or carelessness
caused by others shall be time plus materials work. If any existing conditions are not represented in the specifications or by the principle
necessitating excavation, blasting, plumbing, electrical, concrete, or other work, the same shall be paid by the owner as time plus materials
work.
7.) This contract may be terminated by either party after thirty days written notice. At termination FENCE Landscape Construction shall
conduct a final accounting of time plus materials work done throughout the Contract period and either the Contractor shall reimburse the
Owner or the Owner shall pay the outstanding balance, if any.
8.) Should either party hereto bring suit in court to enforce the terms of this agreement, any judgment awarded shall include court costs
and reasonable attorney’s fees including those on appeal to the successful party plus interest at the legal rate.
9.) The terms of this contract shall bind heirs, executors, administrators, successors, and or/ assigns of both Contractor and Owner as the
terms bind the original parties.
10.) Owner agrees to pay for all of mentioned specifications and cost. Contractor agrees to perform all mentioned specifications to provide
substantial compliance of said specifications. Any necessary substitutions will be made if deemed necessary by the Contractor.
11.) FENCE Landscape Construction is licensed with the Oregon Landscape Contractors board
12.) If any provision, or part of any provision, is found void or unenforceable for any reason all other provisions and parts of provisions
shall be fully enforceable and unaffected.
Owner’s Initials:_________ Date:______________ Contractor’s Initials:_________ Date:_________.", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Customer Contact Status")
    type_code.lookup_item_codes.create!(description: "Active", long_description: "Specifies an active customer contact", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Customer Contact Type")
    type_code.lookup_item_codes.create!(description: "Business Owner", long_description: "This customer is the business owner", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Customer End Reason")
    type_code.lookup_item_codes.create!(description: "Business Closed", long_description: "The Business has closed down", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Customer Status")
    type_code.lookup_item_codes.create!(description: "Active", long_description: "Specifies an active customer", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Email Type")
    type_code.lookup_item_codes.create!(description: "Work", long_description: "Work email address", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Employee End Reason")
    type_code.lookup_item_codes.create!(description: "Retired", long_description: "The employee has retired", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Employee Status")
    type_code.lookup_item_codes.create!(description: "Active", long_description: "Specifies an active employee", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Employee Type")
    type_code.lookup_item_codes.create!(description: "Salary", long_description: "The employee is full time salary", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Manufacturer End Reason")
    type_code.lookup_item_codes.create!(description: "Business Closed", long_description: "The Business has closed down", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Manufacturer Contact Status")
    type_code.lookup_item_codes.create!(description: "Active", long_description: "Specifies an active contact at the manufacturer", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Manufacturer Contact Type")
    type_code.lookup_item_codes.create!(description: "Business Contact", long_description: "Main business contact at the manufacturer", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Manufacturer Status")
    type_code.lookup_item_codes.create!(description: "Active", long_description: "Specifies an active manufacturer", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Phone Status")
    type_code.lookup_item_codes.create!(description: "Active", long_description: "Specifies an active phone number", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Phone Type")
    type_code.lookup_item_codes.create!(description: "Work", long_description: "Work phone number", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Product Category")
    type_code.lookup_item_codes.create!(description: "Material", long_description: "Material product category", business_id: self.id)
    type_code.lookup_item_codes.create!(description: "Labor", long_description: "Labor product category", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Product Status")
    type_code.lookup_item_codes.create!(description: "Active", long_description: "Specifies an active product", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Project Category")
    type_code.lookup_item_codes.create!(description: "Landscape", long_description: "Landscaping project", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Project Group Product Status")
    type_code.lookup_item_codes.create!(description: "Active", long_description: "Specifies an active project group product", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Project Group Status")
    type_code.lookup_item_codes.create!(description: "Active", long_description: "Specifies an active project group", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Proposal Project Group Product Status")
    type_code.lookup_item_codes.create!(description: "Active", long_description: "Specifies an active proposal project group product", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Proposal Project Group Status")
    type_code.lookup_item_codes.create!(description: "Active", long_description: "Specifies an active proposal project group", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Proposal Status")
    type_code.lookup_item_codes.create!(description: "Active", long_description: "Specifies an active proposal", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Supplier Contact Status")
    type_code.lookup_item_codes.create!(description: "Active", long_description: "Supplier contact is active", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Supplier Contact Type")
    type_code.lookup_item_codes.create!(description: "Business Owner", long_description: "Supplier Business owner", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Supplier End Reason")
    type_code.lookup_item_codes.create!(description: "Business Closed", long_description: "The Business has closed down", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Supplier Status")
    type_code.lookup_item_codes.create!(description: "Active", long_description: "Specifies an active supplier", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "Unit of Measure")
    type_code.lookup_item_codes.create!(description: "Each", long_description: "cost for each item", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "User End Reason")
    type_code.lookup_item_codes.create!(description: "Business Closed", long_description: "User closed their business", business_id: self.id)
    type_code = LookupTypeCode.find_by(description: "User Status")
    type_code.lookup_item_codes.create!(description: "Active", long_description: "Specifies an active user", business_id: self.id)


  end

  def must_have_address_and_phone
    if address.nil? and phones.all?{|phone| phone.marked_for_destruction? }
      errors.add(:base, I18n.t('business.atleast_one_address_and_phone'))
    end
  end
end
