class UpdateDonationModuleFrequencyOptionsToIncludeRecurrentWhenAppropriate < ActiveRecord::Migration
  def change
  	DonationModule.all.each do |dm|
  		if dm.frequency_options['one_off'] == 'hidden'
  			dm.frequency_options['one_off'] = 'optional' if !dm.suggested_amounts.try(:empty?) && !dm.default_currency.try(:blank?) && !dm.default_amount.try(:empty?)
  		end
  		if dm.frequency_options['monthly'] == 'hidden'
	      dm.frequency_options['monthly'] = 'optional' if !dm.recurring_suggested_amounts.try(:empty?) && !dm.recurring_default_amount.try(:blank?) && !dm.recurring_default_currency.try(:empty?)
	    end

  		dm.save
  	end
  end
end
