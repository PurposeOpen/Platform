module ListCutter
  class EmailDomainRule < Rule
    fields :domain
    validates_presence_of :domain,  message: 'Please specify the email server'

    def initialize(params={})
      super
      @params[:domain] = cleanup_domain
    end

    def cleanup_domain
      if domain && domain.index('@')
        domain.split('@')[1]
      else
        domain
      end
    end
    private :cleanup_domain

    def to_sql
      sanitize_sql <<-SQL, @movement.id, "%@#{domain}"
        SELECT id AS user_id FROM users
        WHERE movement_id = ? AND email LIKE ?
      SQL
    end
    
    def active?
      !domain.blank?
    end

    def to_human_sql
      "Domain #{is_clause} #{domain}"
    end

  end
end
