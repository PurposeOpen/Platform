module Admin::FormattedTimeAgoHelper

  def time_since_sent(action, occurred)
    if occurred
      "#{action} #{time_ago_in_words(occurred)}"
    else
      "not #{action}"
    end
  end
end
