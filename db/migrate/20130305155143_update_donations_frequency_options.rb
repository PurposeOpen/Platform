class UpdateDonationsFrequencyOptions < ActiveRecord::Migration
  def change
  	DonationModule.all.each do |dm|
  		if !dm.recurring_default_currency.nil? && !dm.recurring_default_currency.empty?
  			dm.frequency_options['monthly'] = 'optional'
  			dm.save
  		end
  	end
  end
end
