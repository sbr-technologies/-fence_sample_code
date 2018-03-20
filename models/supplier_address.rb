class SupplierAddress < ActiveRecord::Base
  belongs_to :business
  belongs_to :supplier
end
