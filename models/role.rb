class Role < ActiveRecord::Base

  ROLE_LEVELS =  {enterprise_admin: 1}

  validates :level, :name, presence: true

  def self.enterprise_admin
    Role.find_by_level ROLE_LEVELS[:enterprise_admin]
  end
end
