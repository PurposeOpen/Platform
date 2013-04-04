module ActsAsClickableFromEmail
  def register_click_from(email, user)
    if email.present? && user.present?
      UserActivityEvent.email_clicked!(user, email, self.is_a?(Page) ? self : nil)
    end
  end
end