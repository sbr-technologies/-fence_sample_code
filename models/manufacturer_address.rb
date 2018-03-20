class ManufacturerAddress < ActiveRecord::Base
  belongs_to :business
  belongs_to :manufacturer
end
