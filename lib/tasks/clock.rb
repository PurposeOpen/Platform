require File.expand_path('../../../config/boot',        __FILE__)
require File.expand_path('../../../config/environment', __FILE__)
require 'clockwork'

include Clockwork

every(5.minute, 'Update member count') { MemberCountCalculator.delay.update_all_counts! }
every(7.minute, 'Update CampaignShareStat') { CampaignShareStat.delay.update! }
every(1.day, 'Preview Pages Cleanup', :at => '05:00') { Page.delay.clean_preview_pages! }
every(1.day, 'Homepage draft cleanup', :at => '05:00') { Homepage.delay.clean_drafts! }
