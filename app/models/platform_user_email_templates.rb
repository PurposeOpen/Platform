module PlatformUserEmailTemplates

  SUBSCRIPTION_CONFIRMATION = <<TEMPLATE
Hi {NAME},

    You've been added as a user for the [Your Name Movement Management Platform].

To access your account, please visit <a href="{PASSWORD_URL}">{PASSWORD_URL}</a> to set a new password.
TEMPLATE

end