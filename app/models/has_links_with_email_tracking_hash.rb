module HasLinksWithEmailTrackingHash

  def add_tracking_hash_to_html_links(text)
    rewrite_links(text, URL_REGEX_HTML, "t={TRACKING_HASH|NOT_AVAILABLE}")
  end

  def add_tracking_hash_to_plain_text_links(text)
    rewrite_links(text, URL_REGEX_PLAIN_TEXT, "t={TRACKING_HASH|NOT_AVAILABLE}")
  end

  private

  def rewrite_links(text, regex, token)
    text.gsub(regex) do |match|
      match.index('?') ? "#{match}&#{token}" : "#{match}?#{token}"
    end
  end
end