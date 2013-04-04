module InlineTokenReplacement

  private

  def replace_tokens(text, tokens={})
    text.gsub token_regex do |_|
      full_match, prefix, token, separator, default = $~.to_a

      replacement = tokens.with_indifferent_access[token]

      if replacement.blank?
        separator.present? ? default : full_match
      else
        replacement = replacement.is_a?(Proc) ? replacement.call(default) : replacement
        [prefix, replacement].join
      end
    end
  end

  def token_regex
    prefix = '(?:\((.*?)\))?'
    default = '([^}]*)'
    /\{#{prefix}(\w+)(\|)?#{default}\}/
  end

end
