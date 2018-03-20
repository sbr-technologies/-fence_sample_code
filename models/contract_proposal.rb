class ContractProposal < ActiveRecord::Base
  STATUS = 'Proposal Status'
  PAYMENT_TERM = 'Contract Proposal -Proposal Payment Terms'
  PROPOSAL_TERM = 'Contract Proposal -Proposal Terms'
  ADDN_PROVISIONS = 'Contract Proposal -Additional Contract Provisions'
  
  monetize :advance_payment, as: :advance, allow_nil: true
  monetize :proposal_amount, as: :amt, allow_nil: true
  
  belongs_to :business
  belongs_to :customer

  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'
  belongs_to :updator, class_name: 'User', foreign_key: 'modified_by'
  belongs_to :preparer, class_name: 'User', foreign_key: 'prepared_by'
  
  has_many :cp_project_groups, dependent: :destroy
  has_many :project_groups, through: :cp_project_groups
  
  default_scope { order(created_at: :desc) }
  
  validates :customer_id, :customer, :proposal_date, :business, :job_number, presence: true
#  validate :uniqueness_of_project
#  validates :project_group_id, uniqueness: {scope: :contract_proposal}
# bart commented out because contact model dropped  validates :signed_by_mi, format: {with: Contact::MIDDLE_INITIAL_REGEX}, if: Proc.new{|p| p.signed_by_mi.present?}
  validates :job_number, uniqueness: { scope: :business, :case_sensitive => false}
  
  after_initialize :init
  after_save  :calculate_amount
  
  scope :customer, lambda{|customer| where('customer_id = ?', customer )}
  scope :project_group, lambda{|project_group| includes(:cp_project_groups).where(:cp_project_groups => { :project_group_id => project_group })}
  scope :start_date, lambda{|start_date| where('proposal_date >= ?', start_date )}
  scope :completion_date, lambda{|completion_date| where('proposal_date <= ?', completion_date )}
  
#  def uniqueness_of_project
#    project_names = cp_project_groups.collect{|p| p.project_group_name unless p.marked_for_destruction? }.compact
#    return if project_names.detect{ |e| project_names.count(e) > 1 }.nil?
#    self.errors.add(:base, 'Cannot same project twice')
#  end

  def self.status_type
    LookupTypeCode.find_by_description(STATUS)
  end

  def self.payment_term_type
    LookupTypeCode.find_by_description(PAYMENT_TERM)
  end

  def self.proposal_term_type
    LookupTypeCode.find_by_description(PROPOSAL_TERM)
  end
  
  def init
    self.status_type_code ||= self.class.status_type.id
    self.cp_proposal_terms_type_code ||= self.class.proposal_term_type.id
    self.cp_payment_terms_type_code ||= self.class.payment_term_type.id
  end
  
  def calculate_amount
    self.update_column(:proposal_amount , cp_project_groups.sum(:cp_pg_amount))
  end
  
  def status
    LookupItemCode.find(self.status_item_code).description unless self.status_item_code.nil?
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
  
  
=begin
Bellow is a temporary method will removed in next sprint
=end
  
def addn_provisions
  type_code = LookupTypeCode.find_by_description(ADDN_PROVISIONS)
  LookupItemCode.find_by(lookup_type_code: type_code.id) unless type_code.blank?
end
  
end
