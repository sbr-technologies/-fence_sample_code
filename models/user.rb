class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
       
  attr_accessor :business_name

  belongs_to :role
  has_one :employee
  validates_confirmation_of :password

  def name
    [last_name, middle_initial, first_name].select(&:present?).join(' ').titleize
  end

  def gravatar_id
    Digest::MD5::hexdigest(email.downcase)
  end
  
  def is_enterprise_admin?
    role && role.level == Role::ROLE_LEVELS[:enterprise_admin]
  end


#  def active_for_authentication?
#    super && self.need_login
#  end
end
