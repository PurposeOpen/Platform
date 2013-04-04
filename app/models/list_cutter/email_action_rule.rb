module ListCutter
  class EmailActionRule < Rule
    fields :email_ids, :action
    validates_presence_of :action, :message => 'Please specify the email status'
    validates_presence_of :email_ids, :message => 'Please specify the email id'

    def to_sql
      activity_table = Push.activity_class_for(action).table_name

      sanitize_sql <<-SQL, @movement.id, email_ids
        SELECT user_id
        FROM #{activity_table}
        WHERE movement_id = ?
        AND email_id IN (?)
        GROUP BY user_id
      SQL
    end

    def active?
      !email_ids.blank?
    end

    def to_human_sql
      email_names = Email.where(:id => email_ids).pluck(:name).join(", ")
      "Email status #{is_clause} #{action.titleize} for email any of these #{email_names}"
    end
  end
end
