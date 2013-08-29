class CreateAdminReportingProviderDomains < ActiveRecord::Migration
  def change
    create_table :admin_reporting_provider_domains do |t|
      t.string :domain
      t.string :provider

      t.timestamps
    end
  end
end
