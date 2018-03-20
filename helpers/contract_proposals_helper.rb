module ContractProposalsHelper

  def date_format(date)
   date.nil? ? '' : date.strftime("%A, %b %d")
  end

  def contract_date_format(contract)
    contract.proposal_date.present? ? contract.proposal_date.strftime('%b %d, %Y') : '' 
  end

  def contract_proposal_status_items
    @business.lookup_item_codes.where({:lookup_type_code_id => ContractProposal.status_type}).collect{|i| [i.description, i.id]}
  end

  def payment_term_items
    @business.lookup_item_codes.where({:lookup_type_code_id => ContractProposal.payment_term_type}).collect{|i| [i.description, i.id]}
  end

  def proposal_term_items
    @business.lookup_item_codes.where({:lookup_type_code_id => ContractProposal.proposal_term_type}).collect{|i| [i.description, i.id]}
  end
end
