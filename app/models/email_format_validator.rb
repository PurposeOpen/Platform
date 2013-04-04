class EmailFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    email_regex = /([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})/i
    record.errors[attribute] << (options[:message] || "should be in format of 'Firstname Lastname <a@b.com>' or 'a@b.com' or 'Name1 & Name2 <a@b.com>'") unless
      value =~ /\A(#{email_regex}|[a-zA-Z\s,\."'&]+<#{email_regex}>)\Z/
  end
end
