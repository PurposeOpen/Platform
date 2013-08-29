class CreateAdminReportingDeliverabilities < ActiveRecord::Migration
  def change
    create_table :admin_reporting_deliverabilities do |t|
      t.date :target_date
      t.text :report

      t.timestamps
    end
  end
end
