class ReadOnly < ActiveRecord::Base
  if AppConstants.readonly_database_url.present?
    establish_connection(AppConstants.readonly_database_url)
  end

  self.abstract_class = true
end