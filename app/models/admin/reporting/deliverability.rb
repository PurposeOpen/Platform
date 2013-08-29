# == Schema Information
#
# Table name: admin_reporting_deliverabilities
#
#  id          :integer          not null, primary key
#  target_date :date
#  report      :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Admin::Reporting::Deliverability < ActiveRecord::Base
  attr_accessible :report, :target_date
  
  validates_presence_of :target_date
  validates_uniqueness_of :target_date
  
  before_create Proc.new { self.report="Generating..."}
  after_create :queue_report
  
  
  
private 

  def queue_report
    Resque.enqueue(::Jobs::DeliverabilityReport,self.id)
  end
  
end
