class CpProjectGroup < ActiveRecord::Base
  STATUS = 'Proposal Project Group Status'
  belongs_to :business
  belongs_to :contract_proposal
  belongs_to :project_group
#  belongs_to :status
  
  has_many :cp_pg_products, dependent: :destroy
  
  has_many :products, through: :cp_pg_products
  
#  before_save :calculate_cp_pg_product_amount
  after_save  :calculate_amount
  after_initialize :init
  
  def self.status_type
    LookupTypeCode.find_by_description(STATUS)
  end
  
  def init
    self.status_type_code ||= self.class.status_type.id

    self.status_item_code ||= self.contract_proposal.status_item_code
    self.created_by ||= self.contract_proposal.created_by
    self.modified_by = self.contract_proposal.modified_by
  end
  
  
#  def calculate_cp_pg_product_amount
#    cp_pg_products.each do |pp|
#      margin_percent = self.contract_proposal.customer.margin_percent
#      if margin_percent.zero? 
#        pp.retail_price = pp.product.retail_price 
#      else
#        pp.retail_price = pp.product.cost_price * ((100+margin_percent)/100)
#      end
##      pp.total_price = pp.retail_price * pp.quantity
##      pp.total_amount = pp.total_price + (pp.labor_cost * pp.labor_hours)
#    end
#  end
  
#  def calculate_amount
#    self.update_column(:amount , project_products.sum(:total_amount))
#  end
  
  def calculate_amount
#    self.update_column(:cp_pg_amount , cp_pg_products.sum(:total_amount))
    total_amount = 0
    cp_pg_products.each do |pp|
      total_amount += pp.total_amount
    end
    self.update_column(:cp_pg_amount , total_amount)
  end
end
