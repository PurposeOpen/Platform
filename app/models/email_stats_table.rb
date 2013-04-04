class EmailStatsTable < ReportTable

  def self.columns
    ["Created", "Sent At", "Blast", "Email", "Sent to", "Opens", "Opens Percentage", "Clicks", "Clicks Percentage", "Actions Taken", "Actions Taken Percentage", "New Members", "New Members Percentage", "Unsubscribed", "Unsubscribed Percentage", "Spam", "Spam Percentage", "Total $", "Avg. $"]
  end

  def initialize(emails)
    @emails = emails
  end

  def rows
    pre_calculate_totals
    @emails.inject([]) { |rows, email| rows << row_for(email); rows }
  end

  def row_for(email)
    stats = load_stats[email.id]
    row   = [
      email.created_at.to_date.to_s,
      email.sent_at.to_s,
      email.blast.name,
      email.name,
      stats[:email_sent][:as_value],
      stats[:email_viewed][:as_value],
      stats[:email_viewed][:as_percentage],
      stats[:email_clicked][:as_value],
      stats[:email_clicked][:as_percentage],
      stats[:action_taken][:as_value],
      stats[:action_taken][:as_percentage],
      stats[:subscribed][:as_value],
      stats[:subscribed][:as_percentage],
      stats[:unsubscribed][:as_value],
      stats[:unsubscribed][:as_percentage],
      stats[:email_spammed][:as_value],
      stats[:email_spammed][:as_percentage]
    ]
    row   += total_and_average_donations_columns(email)
    row
  end

  def load_stats
    @load_stats ||= begin

      stats = init_stats_hash([:email_sent, :email_viewed, :email_clicked, :action_taken, :subscribed, :unsubscribed, :email_spammed])

      stat_objects = UniqueActivityByEmail.where(:email_id => @emails.map(&:id))

      latest_date = get_latest_date(stat_objects)

      stat_objects.each do |stat_obj|
        total      = stat_objects.select { |s| s.email_id == stat_obj.email_id && s.activity.to_sym == :email_sent }
        total      = total.empty? ? 0 : total[0].total_count
        percentage = 0
        ratio      = stat_obj.total_count.to_f / total.to_f
        percentage = ratio * 100 unless total == 0

        stats[stat_obj.email_id][stat_obj.activity.to_sym][:as_value]      = stat_obj.total_count
        stats[stat_obj.email_id][stat_obj.activity.to_sym][:as_percentage] = percentage == 0 ? "N/A" : "#{percentage.round}%" 
      end
      stats[:last_updated_at] = latest_date
      stats
    end
  end

  def get_latest_date(stat_objects)
    sorted_objects = stat_objects.sort_by { |stat| stat.updated_at }
    sorted_objects.blank? ? nil : sorted_objects.last.updated_at
  end

  private :get_latest_date

  def init_stats_hash(activities)
    stats = {}
    @emails.each do |email|
      stats[email.id] = {}
      activities.each do |activity|
        stats[email.id][activity] = {:as_value => 0, :as_percentage => "0%"}
      end
    end
    stats
  end

  def pre_calculate_totals
    @email_totals = @emails.inject({}) do |acc, email|
      acc[email.id] = {:txn_count => 0, :amount_in_cents => 0}
      acc
    end
    totals        = Donation.select('donations.email_id, COUNT(transactions.id) as txn_count, COALESCE(SUM(transactions.amount_in_cents), 0) as amount_in_cents').
        joins(:transactions).
        where(:transactions => {:successful => true}, :donations => {:email_id => @emails.map(&:id)}).
        group('donations.email_id')
    totals.each do |total|
      @email_totals[total.email_id][:txn_count]       = total.txn_count
      @email_totals[total.email_id][:amount_in_cents] = total.amount_in_cents
    end
  end

  def total_and_average_donations_columns(email)
    dollars_raised = @email_totals[email.id][:amount_in_cents] / 100
    columns        = [nil, nil]
    columns[0]     = number_to_currency(dollars_raised)
    if @email_totals[email.id][:txn_count] > 0
      columns[1] = number_to_currency(dollars_raised / @email_totals[email.id][:txn_count])
    end
    columns
  end
end
