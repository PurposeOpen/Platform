# == Schema Information
#
# Table name: languages
#
#  id          :integer          not null, primary key
#  iso_code    :string(255)
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  native_name :string(255)
#

class Language < ActiveRecord::Base
  has_many :movement_locales
  has_many :movements, :through => :movement_locales

  scope :default,     joins(:movement_locales).where(:movement_locales => { :default => true })
  scope :non_default, joins(:movement_locales).where(:movement_locales => { :default => false })

  scope :by_code, lambda {|*codes| where(:iso_code => codes)}

  after_save ->{Rails.cache.delete("language_#{iso_code}")}

  def self.find_by_iso_code_cache(locale)
    Rails.logger.debug "MOVEMENT_PAGE_DEBUG Language cache key: language_#{locale}"
  	Rails.cache.fetch('language_#{locale}', expires_in: 48.hours) do
  	  Language.find_by_iso_code(locale)
  	end
  end
end
