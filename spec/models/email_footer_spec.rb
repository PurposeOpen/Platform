# == Schema Information
#
# Table name: email_footers
#
#  id                 :integer          not null, primary key
#  html               :text
#  movement_locale_id :integer
#  created_by         :string(255)
#  updated_by         :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  text               :text
#

describe 'EmailFooter' do
  it 'should have the html links appended with email tracking hash token' do
    footer = EmailFooter.new(:html => 'Hey, <a href="http://platform.com/link1">you</a>!', :text => 'Hey, you - http://platform.com/bla !')

    footer.html.should eql 'Hey, <a href="http://platform.com/link1?t={TRACKING_HASH|NOT_AVAILABLE}">you</a>!'
    footer.text.should eql 'Hey, you - http://platform.com/bla?t={TRACKING_HASH|NOT_AVAILABLE} !'
  end

  it 'should have the html link appended with email tracking hash token and with the beacon' do
    footer = FactoryGirl.create(:email_footer,
        :html => 'Hey, <a href="http://platform.com/link1">you</a>!',
        :text => 'Hey, you - http://platform.com/bla !')
    footer.movement_locale = FactoryGirl.create(:movement_locale, 
        :movement => FactoryGirl.create(:movement, :url => "http://movement-yeah.com"),
        :email_footer => footer)

    footer.html_with_beacon.should eql 'Hey, <a href="http://platform.com/link1?t={TRACKING_HASH|NOT_AVAILABLE}">you</a>!<img src="http://movement-yeah.com/beacon.gif?t={TRACKING_HASH|NOT_AVAILABLE}">'
  end

  context 'movement url and links in email are https,' do
    it 'should generate a valid beacon url and links should be https' do
      footer = FactoryGirl.create(:email_footer,
        :html => 'Hey, <a href="https://platform.com/link1">you</a>!',
        :text => 'Hey, you - https://platform.com/bla !')

      footer.movement_locale = FactoryGirl.create(:movement_locale, 
        :movement => FactoryGirl.create(:movement, :url => "https://movement-yeah.com"),
        :email_footer => footer)

      footer.html_with_beacon.should eql 'Hey, <a href="https://platform.com/link1?t={TRACKING_HASH|NOT_AVAILABLE}">you</a>!<img src="https://movement-yeah.com/beacon.gif?t={TRACKING_HASH|NOT_AVAILABLE}">'
    end
  end
end
