module Jobs
  class DeliverabilityReport
    @queue = :reporting
  
    def self.perform(report_id)
      report=Admin::Reporting::Deliverability.find(report_id)
      
      report.report = ""
      
      #ActiveRecord::Base.connection.execute 'SET TRANSACTION ISOLATION LEVEL READ COMMITTED' 
      ActiveRecord::Base.transaction do    
#         sent_stats_query = %Q{
#           (SELECT pushes.email_id as email_id, COALESCE(domains.provider,'other') as provider, count(pushes.email_id) as sent_count FROM users u 
#           LEFT OUTER JOIN admin_reporting_provider_domains domains ON SUBSTRING_INDEX(u.email, '@', -1)=domains.domain 
#           JOIN     
#           	(SELECT ps.email_id, ps.user_id FROM push_sent_emails ps JOIN emails e ON ps.email_id=e.id
#           	WHERE (e.sent_at BETWEEN '#{report.target_date.to_time}' and '#{report.target_date + 24.hours}') GROUP BY ps.email_id, ps.user_id) AS pushes 
#           ON u.id=pushes.user_id
#           GROUP BY pushes.email_id, provider)          
#         }
#         
#         viewed_stats_query = %Q{
#             (SELECT pushes.email_id as email_id, COALESCE(domains.provider,'other') as provider, count(pushes.email_id) as unique_open_count FROM users u 
#             LEFT OUTER JOIN admin_reporting_provider_domains domains ON SUBSTRING_INDEX(u.email, '@', -1)=domains.domain 
#             JOIN     
#             	(SELECT pv.email_id, pv.user_id FROM push_viewed_emails pv JOIN emails e ON pv.email_id=e.id
#             	WHERE (e.sent_at BETWEEN '#{report.target_date.to_time}' and '#{report.target_date + 24.hours}') GROUP BY pv.email_id, pv.user_id) AS pushes 
#             ON u.id=pushes.user_id
#             GROUP BY pushes.email_id, provider)                   
#         }


        sent_stats_query = %Q{
          (SELECT pushes.email_id as email_id, COALESCE(domains.provider,'other') as provider, count(pushes.email_id) as sent_count FROM users u 
          LEFT OUTER JOIN admin_reporting_provider_domains domains ON SUBSTRING_INDEX(u.email, '@', -1)=domains.domain 
          JOIN     
          	(SELECT ps.email_id, ps.user_id FROM push_sent_emails ps JOIN emails e ON ps.email_id=e.id
          	WHERE (e.sent_at BETWEEN '#{report.target_date.to_time}' and '#{report.target_date + 24.hours}') GROUP BY ps.email_id, ps.user_id) AS pushes 
          ON u.id=pushes.user_id
          GROUP BY provider)          
        }
        
        viewed_stats_query = %Q{
            (SELECT pushes.email_id as email_id, COALESCE(domains.provider,'other') as provider, count(pushes.email_id) as unique_open_count FROM users u 
            LEFT OUTER JOIN admin_reporting_provider_domains domains ON SUBSTRING_INDEX(u.email, '@', -1)=domains.domain 
            JOIN     
            	(SELECT pv.email_id, pv.user_id FROM push_viewed_emails pv JOIN emails e ON pv.email_id=e.id
            	WHERE (e.sent_at BETWEEN '#{report.target_date.to_time}' and '#{report.target_date + 24.hours}') GROUP BY pv.email_id, pv.user_id) AS pushes 
            ON u.id=pushes.user_id
            GROUP BY provider)                   
        }

        
        sent_stats_result = ActiveRecord::Base.connection.exec_query sent_stats_query      
        viewed_stats_result = ActiveRecord::Base.connection.exec_query viewed_stats_query



        
        combined_stats={}
        
        sent_stats_result.to_hash.each do |sent_row|
          combined_stats[sent_row['provider']] ||= {}
          combined_stats[sent_row['provider']]['sent_count']=sent_row['sent_count']
        end
        
        viewed_stats_result.to_hash.each do |viewed_row|
          combined_stats[viewed_row['provider']] ||= {}
          combined_stats[viewed_row['provider']]['unique_open_count']=viewed_row['unique_open_count']
        end
        
        puts combined_stats.inspect
        
        combined_stats.each do |k,v|
          begin 
            percent=((combined_stats[k]['unique_open_count'].to_f/combined_stats[k]['sent_count'].to_f)*100).round(2)
          rescue
            puts k,v
            puts $!
            percent=0
          end
          
          combined_stats[k]['percent']=percent
        end        
      

        report.report << "<br> Combined Stats for Emails Sent on #{report.target_date} <br>"
        report.report << table_format(['provider','sent_count','unique_open_count','percent'], combined_stats.collect {|k,v| [k,v['sent_count'],v['unique_open_count'],v['percent']] })        

        
      
#         report.report << "<br> Sent Stats for #{report.target_date} <br>"
#         report.report << table_format(sent_stats_result.columns, sent_stats_result.rows)
#         
#         report.report << "<br> Unique Viewed Stats for #{report.target_date} <br>"
#         report.report << table_format(viewed_stats_result.columns, viewed_stats_result.rows)

          
        #domain #sent #unique_opens #percent
      end 
      
      report.save    
    end
    
    
    def self.table_format(columns,rows)
      table = "<table>"
    
      table << "<tr>"
      columns.each {|column| table << "<th>#{column}</th>"}
      table << "</tr>"
     

      rows.each do |row|
        table << "<tr>" 
        row.each {|value| table << "<td>#{value}</td>"}
        table << "</tr>"      
      end

    
      table << "</table>"
    end
    
          
  end
end
