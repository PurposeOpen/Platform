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
end
