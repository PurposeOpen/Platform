class SetAllSidebarContentModulesToActive < ActiveRecord::Migration
  def up
    ensure_there_are_no_donation_modules_with_suggested_amounts_as_string

    set_content_module_active_flag(PetitionModule, 'true')
    set_content_module_active_flag(DonationModule, 'true')
    set_content_module_active_flag(EmailTargetsModule, 'true')
    set_content_module_active_flag(JoinModule, 'true')
  end

  def down
    set_content_module_active_flag(PetitionModule, nil)
    set_content_module_active_flag(DonationModule, nil)
    set_content_module_active_flag(EmailTargetsModule, nil)
    set_content_module_active_flag(JoinModule, nil)
  end

  def set_content_module_active_flag(content_module_klass, active_flag)
    content_module_klass.all.each do |content_module|
      content_module.active = active_flag
      content_module.save
    end
  end

  def ensure_there_are_no_donation_modules_with_suggested_amounts_as_string
    DonationModule.all.each do |donation_module|
      if donation_module.suggested_amounts.class == String
        donation_module.suggested_amounts = {}
        donation_module.save!
      end
    end
  end
end
