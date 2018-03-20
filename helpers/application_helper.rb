module ApplicationHelper

  BOOTSTRAP_FLASH_MSG = {
    success: 'alert-success',
    error: 'alert-danger',
    alert: 'alert-danger',
    notice: 'alert-info'
  }

  def bootstrap_class_for(flash_type)
    BOOTSTRAP_FLASH_MSG.fetch(flash_type.to_sym)
  end

  def profile_image_for(user, options={})
    size = options[:size] || 80
    url = "https://secure.gravatar.com/avatar/#{user.gravatar_id}?s=#{size}"
    image_tag(url, alt: user, :class =>"img-circle")
  end
  
  def phone_type_items
    @business.lookup_item_codes.where({:lookup_type_code_id => LookupTypeCode.phone_type_code}).collect{|i| [i.description, i.id]}
  end

#Bart commented out 2-6-16
#  def phone_type_options
#    @business.phone_types.collect{|p| [p.description, p.id]}.sort_by!{ |t| t[0].downcase }
#  end
#
#  def unit_of_measurement_options 
#    @business.unit_of_measurements.collect{|p| [p.description, p.id]}.sort_by!{ |t| t[0].downcase }
#  end
#  
#  def status_options
#    @business.statuses.collect{|p| [p.title, p.id]}
#  end
  
end
