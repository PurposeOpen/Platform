FactoryGirl.define do
  sequence :time do |x|
    Time.now - x.hours
  end

  sequence :date do |x|
    Date.today - x.days
  end

  sequence :email do |x|
    "person#{x}@example.com"
  end

  sequence :postcode_number do |x|
    "#{x.to_s.rjust(4, "0")}"
  end
end