# == Schema Information
#
# Table name: movement_locales
#
#  id          :integer          not null, primary key
#  movement_id :integer
#  language_id :integer
#  default     :boolean          default(FALSE)
#

class MovementLocale < ActiveRecord::Base
  belongs_to :movement
  belongs_to :language
  has_one :join_email, :dependent => :destroy
  has_one :email_footer, :dependent => :destroy

  validates_uniqueness_of :movement_id, :scope => [:language_id]

  after_create :ensure_join_email_exists
  after_create :ensure_email_footer_exists

  scope :default,     where(:default => true)
  scope :non_default, where(:default => false)
  scope :by_code,     lambda { |code| joins(:language).where(:languages => { :iso_code => code }) }

  delegate :iso_code, :to => :language

  private

  def ensure_join_email_exists
    unless self.join_email
      self.join_email = JoinEmail.new(
        :movement_locale => self, 
        :body => "",
        :from => "",
        :subject => "",
        :reply_to => ""
      )
      self.join_email.save!
    end
  end

  def ensure_email_footer_exists
    unless self.email_footer
      self.email_footer = EmailFooter.new(:movement_locale => self, :html => "", :text => "")
      self.email_footer.save!
    end
  end
end
