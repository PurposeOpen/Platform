module MailConfigulator

  def target_email_settings(movement)
    email_settings('TARGET_EMAIL', movement)
  end

  def blast_email_settings(movement)
    email_settings('BLAST_EMAIL', movement)
  end

  def email_settings(type, movement)
    movement_name = movement.name.upcase.gsub(' ', '')
    {:user_name => ENV["#{movement_name}_#{type}_USERNAME"],
     :password => ENV["#{movement_name}_#{type}_PASSWORD"],
     :domain => ENV["#{movement_name}_#{type}_DOMAIN"]}
  end

end