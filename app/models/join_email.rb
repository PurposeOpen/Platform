# == Schema Information
#
# Table name: join_emails
#
#  id                 :integer          not null, primary key
#  subject            :string(255)
#  body               :text
#  movement_locale_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  from               :string(255)
#  created_by         :string(255)
#  updated_by         :string(255)
#  reply_to           :string(255)
#

class JoinEmail < ActiveRecord::Base
  acts_as_user_stampable

  belongs_to :movement_locale
  has_one :movement, through: :movement_locale
  has_one :language, through: :movement_locale

  validates_uniqueness_of :movement_locale_id

  alias_attribute :html_body, :body
  alias_attribute :plain_text_body, :body

  def footer
    movement.footer_for_language(language.iso_code)
  end

end
