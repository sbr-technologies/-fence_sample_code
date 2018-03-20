class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, Business, id: user.business_id
    can :manage, [ContractProposal, ProjectGroup, Product, Supplier, Manufacturer, Customer, Employee], business_id: user.business_id
  end
end
