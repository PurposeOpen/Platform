class AskStatsTable < ReportTable    
  def self.columns
    ['Created', 'Action Sequence', 'Page', 'Ask Type', 'Actions', 'New Members', 'Total $', 'Avg. $']
  end

  def initialize(stats)
    @stats = stats
  end

  def rows
    rows = []
    @stats.each do |stat|
      rows << row_for(stat)
    end
    rows
  end

  def row_for(stat)
    row = [
      stat.created_at.to_date.to_s,
      stat.action_sequence_name,
      stat.page_name,
      stat.type.underscore.humanize,
      stat.actions_taken.to_i,
      stat.subscriptions.to_i
    ]
    row += total_and_average_donations_columns(stat)
    row
  end

  private

  def total_and_average_donations_columns(stat)
    donation_stats = Donation.stats_by_action_page(stat.page_id)
    total_actions = donation_stats[0]
    total = donation_stats[1] / 100
    formatted_total = number_to_currency(total)
    average = total_actions > 0 ? number_to_currency(total / total_actions) : nil
    [formatted_total, average]
  end
end