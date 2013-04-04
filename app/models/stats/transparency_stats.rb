class Stats::TransparencyStats
    
  def update
    stats = Rails.cache.read('transparency_stats')
    return stats unless stats.nil?
    
    target_by_the_numbers = Hash.new
    target_by_the_numbers[:day] = {}
    target_by_the_numbers[:week] = {}
    target_by_the_numbers[:month] = {}
    target_by_the_numbers[:year] = {}
    
    donations = donations_count

    target_by_the_numbers[:day][:nb_donations] = donations[0].to_i
    target_by_the_numbers[:week][:nb_donations] = donations[1].to_i
    target_by_the_numbers[:month][:nb_donations] = donations[2].to_i
    target_by_the_numbers[:year][:nb_donations] = donations[3].to_i + 36873 #108313
     
    target_by_the_numbers[:day][:total_donations] = donations[4].to_i/100
    target_by_the_numbers[:week][:total_donations] = donations[5].to_i/100
    target_by_the_numbers[:month][:total_donations] = donations[6].to_i/100
    target_by_the_numbers[:year][:total_donations] = donations[7].to_i/100 + 1534247 #4417109
     
    target_by_the_numbers[:day][:average_donations] = donations[8].to_i/100
    target_by_the_numbers[:week][:average_donations] = donations[9].to_i/100
    target_by_the_numbers[:month][:average_donations] = donations[10].to_i/100
    target_by_the_numbers[:year][:average_donations] = donations[11].to_i/100
     
    actions_taken = actions_taken_count
    
    target_by_the_numbers[:day][:actions_taken] = actions_taken[0].to_i
    target_by_the_numbers[:week][:actions_taken] = actions_taken[1].to_i
    target_by_the_numbers[:month][:actions_taken] = actions_taken[2].to_i
    target_by_the_numbers[:year][:actions_taken] = actions_taken[3].to_i + 467997 #584106
    
    new_members = new_members_count
    target_by_the_numbers[:day][:new_members] = new_members[0].to_i
    target_by_the_numbers[:week][:new_members] = new_members[1].to_i
    target_by_the_numbers[:month][:new_members] = new_members[2].to_i
    target_by_the_numbers[:year][:new_members] = new_members[3].to_i + 98803 #81777
    
    donors = donors_count
    target_by_the_numbers[:day][:donors] = donors[0].to_i
    target_by_the_numbers[:week][:donors] = donors[1].to_i
    target_by_the_numbers[:month][:donors] = donors[2].to_i
    target_by_the_numbers[:year][:donors] = donors[3].to_i + 42779
    
    first_donors = first_donors_count
    target_by_the_numbers[:day][:first_donors] = first_donors[0].to_i
    target_by_the_numbers[:week][:first_donors] = first_donors[1].to_i
    target_by_the_numbers[:month][:first_donors] = first_donors[2].to_i
    target_by_the_numbers[:year][:first_donors] = first_donors[3].to_i + 18765 #26637

    target_by_the_numbers[:last_time_calculated] = Time.zone.now
    
    Rails.cache.write('transparency_stats', target_by_the_numbers, :expires_in => 24.hours)
    
    target_by_the_numbers
  end


  def actions_taken_count
    sql = <<SQL
    select 
      SUM(IF(created_at > DATE_SUB(NOW(),INTERVAL 1 DAY), 1, 0)) as nb_actions_taken_day,
      SUM(IF(created_at > DATE_SUB(NOW(),INTERVAL 1 WEEK), 1, 0)) as nb_actions_taken_week,  
      SUM(IF(created_at > DATE_SUB(NOW(),INTERVAL 1 MONTH), 1, 0)) as nb_actions_taken_month,  
      SUM(IF(created_at > DATE_SUB(NOW(),INTERVAL 1 YEAR), 1, 0)) as nb_actions_taken_year  
    from user_activity_events 
    where activity = "action_taken"
SQL
    ActiveRecord::Base.connection.execute(sql).to_a.flatten
  end


  def new_members_count
    sql = <<SQL
    select 
      SUM(IF(created_at > DATE_SUB(NOW(),INTERVAL 1 DAY), 1, 0)) as nb_new_members_day,
      SUM(IF(created_at > DATE_SUB(NOW(),INTERVAL 1 WEEK), 1, 0)) as nb_new_members_week,
      SUM(IF(created_at > DATE_SUB(NOW(),INTERVAL 1 MONTH), 1, 0)) as nb_new_members_month,
      SUM(IF(created_at > DATE_SUB(NOW(),INTERVAL 1 YEAR), 1, 0)) as nb_new_members_year
    from user_activity_events
    where activity = "subscribed"
SQL
    ActiveRecord::Base.connection.execute(sql).to_a.flatten
  end

  def donations_count
    sql = <<SQL
    select 
      SUM(IF(t.created_at > DATE_SUB(NOW(),INTERVAL 1 DAY), 1, 0)) as nb_donations_day,
      SUM(IF(t.created_at > DATE_SUB(NOW(),INTERVAL 1 WEEK), 1, 0)) as nb_donations_week,
      SUM(IF(t.created_at > DATE_SUB(NOW(),INTERVAL 1 MONTH), 1, 0)) as nb_donations_month,
      SUM(IF(t.created_at > DATE_SUB(NOW(),INTERVAL 1 YEAR), 1, 0)) as nb_donations_year,
      SUM(IF(t.created_at > DATE_SUB(NOW(),INTERVAL 1 DAY), t.amount_in_cents, 0)) as total_donations_day,
      SUM(IF(t.created_at > DATE_SUB(NOW(),INTERVAL 1 WEEK), t.amount_in_cents, 0)) as total_donations_week,
      SUM(IF(t.created_at > DATE_SUB(NOW(),INTERVAL 1 MONTH), t.amount_in_cents, 0)) as total_donations_month,
      SUM(IF(t.created_at > DATE_SUB(NOW(),INTERVAL 1 YEAR), t.amount_in_cents, 0)) as total_donations_year,
      CAST(SUM(IF(t.created_at > DATE_SUB(NOW(),INTERVAL 1 DAY), t.amount_in_cents, 0)) / SUM(IF(t.created_at > DATE_SUB(NOW(),INTERVAL 1 DAY), 1, 0)) AS DECIMAL (20,2)) avg_donation_day,
      CAST(SUM(IF(t.created_at > DATE_SUB(NOW(),INTERVAL 1 WEEK), t.amount_in_cents, 0)) / SUM(IF(t.created_at > DATE_SUB(NOW(),INTERVAL 1 WEEK), 1, 0)) AS DECIMAL (20,2)) avg_donation_week,
      CAST(SUM(IF(t.created_at > DATE_SUB(NOW(),INTERVAL 1 MONTH), t.amount_in_cents, 0)) / SUM(IF(t.created_at > DATE_SUB(NOW(),INTERVAL 1 MONTH), 1, 0)) AS DECIMAL (20,2)) avg_donation_month,
      CAST((SUM(IF(t.created_at > DATE_SUB(NOW(),INTERVAL 1 YEAR), t.amount_in_cents, 0))+ 153424700) / (SUM(IF(t.created_at > DATE_SUB(NOW(),INTERVAL 1 YEAR), 1, 0))+36873) AS DECIMAL (20,2)) avg_donation_year
    from donations d join transactions t on d.id=t.donation_id where t.successful=true
SQL
    ActiveRecord::Base.connection.execute(sql).to_a.flatten
  end

  def donors_count
    sql = <<SQL
    select
      SUM(IF(min_last_donated_at > DATE_SUB(NOW(),INTERVAL 1 DAY), 1, 0)) as nb_donors_day,
      SUM(IF(min_last_donated_at > DATE_SUB(NOW(),INTERVAL 1 WEEK), 1, 0)) as nb_donors_week,
      SUM(IF(min_last_donated_at > DATE_SUB(NOW(),INTERVAL 1 MONTH), 1, 0)) as nb_donors_month,
      SUM(IF(min_last_donated_at > DATE_SUB(NOW(),INTERVAL 1 YEAR), 1, 0)) as nb_donors_year  
    from (
      select user_id, MAX(last_donated_at) as min_last_donated_at from donations group by user_id
    ) as t
SQL
    ActiveRecord::Base.connection.execute(sql).to_a.flatten
  end


  def first_donors_count
    sql = <<SQL
    select
      SUM(IF(min_last_donated_at > DATE_SUB(NOW(),INTERVAL 1 DAY), 1, 0)) as nb_first_donors_day,
      SUM(IF(min_last_donated_at > DATE_SUB(NOW(),INTERVAL 1 WEEK), 1, 0)) as nb_first_donors_week,
      SUM(IF(min_last_donated_at > DATE_SUB(NOW(),INTERVAL 1 MONTH), 1, 0)) as nb_first_donors_month,
      SUM(IF(min_last_donated_at > DATE_SUB(NOW(),INTERVAL 1 YEAR), 1, 0)) as nb_first_donors_year
    from (
      select user_id, MIN(created_at) as min_last_donated_at from donations group by user_id
    ) as t
SQL
    ActiveRecord::Base.connection.execute(sql).to_a.flatten
  end

end
