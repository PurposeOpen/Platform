class EmailTrackingHash < Struct.new(:email, :user)

  def self.decode(hash)
    hash ||= ""
    data_pairs = Base64.urlsafe_decode64(hash).split ","
    attrs = data_pairs.inject({}) do |hash, pair|
      key, value = pair.split "="
      hash.merge key.to_sym => value
    end

    email = Email.where(id: attrs[:emailid]).first
    user  = User.where(id: attrs[:userid]).first

    self.new email, user
  rescue ArgumentError # "invalid base64"
    self.new nil, nil
  end

  def valid?
    email.present? && email.is_a?(Email) && user.present? && user.is_a?(User)
  end

  def encode
    if email.is_a?(AutofireEmail) || email.is_a?(JoinEmail)
      ""
    else
      raise "Cannot encode invalid tracking hash; requires an email (was: #{self.email}) and a user (was: #{self.user})" unless valid?
      Base64.urlsafe_encode64("userid=#{self.user.id},emailid=#{self.email.id}")
    end
  end

  def email_id
    self.email.try(:id)
  end

  def user_id
    self.user.try(:id)
  end
end