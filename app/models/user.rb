# == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  email                    :string(255)      not null
#  first_name               :string(64)
#  last_name                :string(64)
#  mobile_number            :string(32)
#  home_number              :string(32)
#  street_address           :string(128)
#  suburb                   :string(64)
#  country_iso              :string(2)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  is_member                :boolean          default(TRUE), not null
#  encrypted_password       :string(255)      default("!K1T7en$!!2011G")
#  password_salt            :string(255)
#  reset_password_token     :string(255)
#  reset_password_sent_at   :datetime
#  remember_created_at      :datetime
#  sign_in_count            :integer          default(0)
#  current_sign_in_at       :datetime
#  last_sign_in_at          :datetime
#  current_sign_in_ip       :string(255)
#  last_sign_in_ip          :string(255)
#  deleted_at               :datetime
#  is_admin                 :boolean          default(FALSE)
#  created_by               :string(255)
#  updated_by               :string(255)
#  is_volunteer             :boolean          default(FALSE)
#  random                   :float
#  movement_id              :integer          not null
#  language_id              :integer
#  postcode                 :string(255)
#  join_email_sent          :boolean
#  name_safe                :boolean
#  source                   :string(255)
#  permanently_unsubscribed :boolean
#  state                    :string(64)
#

class User < ActiveRecord::Base
  include CacheableModel
  acts_as_paranoid
  acts_as_user_stampable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable

  attr_accessor :required_user_details
  cattr_accessor :current_user

  belongs_to :movement
  belongs_to :language
  has_many :user_activity_events
  has_many :events_hosted, :class_name => "Event", :foreign_key => "host_id"
  has_many :donations
  has_many :agra_actions

  has_and_belongs_to_many :events_attended, :class_name => "Event", :association_foreign_key => "event_id",
                          :foreign_key => "attendee_id", :join_table => "events_attendees"
  
  before_validation :profanalyze_name
  before_validation :downcase_email
  before_validation :ensure_source_is_present

  validates_presence_of :email, :source
  validates_format_of :email, :with => VALID_EMAIL_REGEX
  validates_uniqueness_of :email, :scope => :movement_id

  before_save :downcase_email
  after_create :assign_random_value

  scope :for_movement, lambda { |movement| where(:movement_id => movement.try(:id)) }
  scope :subscribed, where(:is_member => true)
  scope :unsubscribed, where(:is_member => false)
  scope :subscribed_to, lambda { |movement| subscribed.for_movement(movement) }

  searchable do
    text :id
    text :first_name
    text :last_name
    text :email
    boolean :is_admin
    time :updated_at
  end
  handle_asynchronously :solr_index

  class << self
    def update_random_values
      self.connection.execute("update users set random = rand()")
    end

    def find_by_email(address)
      User.where(["email = ?", address.downcase]).first unless address.nil?
    end

    def possibly_required_field(field, constraints = {})
      must_be_present_if_required = {:presence => {:if => lambda { [:required, :refresh].include? (@required_user_details || {})[field] }}}
      validates field, must_be_present_if_required.merge(constraints)
    end
  end

  possibly_required_field :first_name, :length => {:maximum => 40}
  possibly_required_field :last_name, :length => {:maximum => 40}
  possibly_required_field :home_number, :length => {:maximum => 32}
  possibly_required_field :mobile_number, :length => {:maximum => 32}
  possibly_required_field :street_address, :length => {:maximum => 128}
  possibly_required_field :suburb, :length => {:maximum => 128}
  possibly_required_field :country_iso
  possibly_required_field :postcode_number, :length => {:maximum => 16}

  def already_entered?(field)
    !self.new_record? && !self.send(field).blank?
  end

  def entered_fields
    attributes.select {|k,v| v.present? }.keys
  end

  # TODO Deprecate/remove this.
  def save_with_valid_email(required_user_details, user_details, page, ask, email)
    @subscribed_from_page = page
    @subscribed_from_ask = ask
    @subscribed_from_email = email
    self.update_attributes(user_details)
    @required_user_details = required_user_details
    self.valid?
  end

  def greeting
    first_name.blank? ? nil : CGI::escapeHTML(first_name.titlecase)
  end

  def full_name
    joined = "#{first_name} #{last_name}".strip
    CGI::escapeHTML(joined.blank? ? 'Unknown Username' : joined.titlecase)
  end
  alias_method :name, :full_name

  def postcode_number=(number)
    self.postcode = number
  end

  def postcode_number
    self.postcode
  end

  def take_action_on!(page, action_info = {}, new_attributes = self.attributes)
    self.attributes = new_attributes
    subscribe_through!(page, action_info[:email]) if page.subscribes_user?
    page.process_action_taken_by(self, action_info)
  end

  def subscribe_through_homepage!(email=nil)
    return unless self.can_subscribe?

    self.is_member = true
    self.source = :movement
    save!
    join_page = movement.join_page
    UserActivityEvent.subscribed!(self, email, join_page, join_page.ask_module_for_language(self.language)) unless is_already_subscribed?
  end

  def subscribe_through!(page, email=nil)
    return unless self.can_subscribe?

    self.is_member = true
    self.source = :movement
    save!
    UserActivityEvent.subscribed!(self, email, page, page.ask_module_for_language(self.language)) unless is_already_subscribed?
  end

  def unsubscribe!(email = nil, reason=nil)
    unless self.new_record?
      self.transaction do
        self.is_member = false
        UserActivityEvent.unsubscribed!(self,email,reason)
        self.save!
      end
    end
  end

  def permanently_unsubscribe!(email = nil, reason = nil)
    self.unsubscribe!(email,reason)
    self.update_attribute :permanently_unsubscribed, true
  end

  def can_subscribe?
    !self.permanently_unsubscribed
  end

  def successful_transactions
    self.transactions.where("transactions.successful" => true)
  end

  def cache_key
    self.class.generate_cache_key(self.email)
  end

  def self.umbrella_user
    find_by_email(AppConstants.umbrella_user_email_address)
  end

  def member?;
    is_member;
  end

  def language_iso_code
    language.try(:iso_code).try(:upcase)
  end

  def country_iso_code
    country_iso.try(:upcase)
  end

  def assign_random_value
    self.connection.execute("update users set random = rand() where id = #{self.id} and movement_id = #{self.movement_id}")
    self.reload
  end

  private

  def async_assign_random_value
    Resque.enqueue(Jobs::AssignRandomValueToUser, self.id)
  end

  def downcase_email
    self.email = self.email.downcase if self.email
  end

  def is_already_subscribed?
    UserActivityEvent.where(:user_id => self.id, :activity => UserActivityEvent::Activity::SUBSCRIBED).any?
  end

  def profanalyze_name
    self.name_safe = Profanalyzer.profane?(self.name) ? false : true
    return true
  end

  def ensure_source_is_present
    self.source = :movement if self.source.nil?
  end
end
