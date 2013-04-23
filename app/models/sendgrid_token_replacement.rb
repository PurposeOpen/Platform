require 'uri'

module SendgridTokenReplacement
  TOKENS_REGEX = /\{([^\{]*\|[^\{]*)\}/m #matches tokens of the form {TOKEN_NAME|DEFAULT_VALUE}

  private

  def get_substitutions_list(email, options)
    # we group by email in the following query to safe guard against duplicate email addresses, a legacy from v2
    users = User.where(:email => options[:recipients], :movement_id => email.movement).order(:email).group(:email)
    create_temporary_user_entries_for_non_members(options[:recipients], users)
    generate_replacement_tokens(email, users, options[:test] ? options[:recipients] : nil, options[:test])
  end

  def create_temporary_user_entries_for_non_members(recipients, users)
    return '' unless recipients
    recipients.each do |email_address|
      users << User.new(:email => email_address) unless users.find { |user|  user.email == email_address }
    end
  end

  def generate_replacement_tokens(email, users, recipients = nil, is_test = false)
    sub = {}
    text_to_scan = %{
    #{email.subject}
    #{email.html_body}
    #{email.plain_text_body}
    #{email.footer.html}
    #{email.footer.text}
    }
    text_to_scan.scan(TOKENS_REGEX).uniq.each do |token_pair|
      token_name, default_value = token_pair[0].split("|")
      default_value ||= "";
      case token_name
        when "NAME" then
          set_tokens(sub, default_value, token_name, users, recipients) do |u|
            u.first_name.blank? ? default_value : u.first_name
          end
        when "EMAIL" then
          set_tokens(sub, default_value, token_name, users, recipients) do |u|
            u.email.blank? ? default_value : u.email
          end
        when "MOVEMENT_URL" then
          set_tokens(sub, default_value, token_name, users, recipients) do |u|
            email.movement.url.blank? ? default_value : email.movement.url
          end
        when "POSTCODE" then
          set_tokens(sub, default_value, token_name, users, recipients) do |u|
            u.postcode_number.blank? ? default_value : u.postcode_number
          end
      end
    end
    set_tokens(sub, "NOT_AVAILABLE", "TRACKING_HASH", users, recipients) do |u|
      u.persisted? && !is_test ? EmailTrackingHash.new(email, u).encode : "NOT_AVAILABLE"
    end
    sub
  end

  def set_tokens(sub, default_value, token_name, users, recipients, &block)
    result = nil
    if recipients
      result = [default_value] * recipients.length
      users.each do |u|
        result[recipients.index(u.email)] = block.call(u)
      end
    else
      result = users.blank? ? [default_value] : users.map { |u| block.call(u) }
    end

    sub["{#{token_name}|#{default_value}}"] = result
  end
end