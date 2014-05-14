module ListCutter
  class DonorRule < Rule
    fields :frequencies
    validates_presence_of :frequencies, message: 'Please specify a frequency'

    def to_sql
      sanitize_sql <<-SQL, frequencies
        SELECT user_id FROM donations
        WHERE frequency IN (?)
        AND active = 1
        GROUP BY user_id
      SQL
    end
    
    def active?
      !frequencies.blank?
    end

    def to_human_sql
      "Donation frequency #{is_clause} #{frequencies}"
    end

  end
end
