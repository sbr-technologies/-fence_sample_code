class ContractProposalSerializer < ActiveModel::Serializer
  attributes :id, :job_number, :job_description, :customer, :amount, :proposal_date, :proposal_date_text, :start_date, :start_date_text, :completion_date, :completion_date_text, :status_item_code, :status
  
  def customer
    Customer.find(object.customer_id).name
  end
  
  def amount
    object.proposal_amount.to_money.format
  end
  
  def proposal_date_text
    proposal_date.to_s
  end
  
  def start_date_text
    start_date.to_s
  end
  
  def completion_date_text
    completion_date.to_s
  end
end