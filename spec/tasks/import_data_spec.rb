require 'spec_helper'

require 'rake'
describe "should import data from csv correctly", :wip=>'true' do
  before do
    rake = Rake::Application.new
    Rake.application = rake
    Rake::Task.define_task(:environment)
    load "#{Rails.root}/lib/tasks/import_data.rake"
    rake["import:postcodes"].invoke
  end

  after :all do
    Postcode.delete_all
  end

  it "should import Sydney postcodes '2000' data from csv correctly" do
    postcode = Postcode.find_by_number("2000")
    postcode.id.should == 1754
    postcode.suburbs.match (/^Circular Quay\\+\SDarling Harbour\\+\SDawes Point\\+\SGoat Island\\+\SMillers Point\\+\SSt James\\+\SSydney\\+\SSydney South\\+\SThe Rocks\\+\S$/)
    postcode.state.should == "NSW"
    postcode.longitude.should == 151.21
    postcode.latitude.should == -33.86
  end

  it "should import Melbourne postcodes '3000' data from csv correctly" do
    postcode = Postcode.find_by_number("3000")
    postcode.id.should == 1556
    postcode.suburbs.match (/^Carlton South\\+\SMelbourne\\+\SMuseum\\+\S$/)
    postcode.state.should == "VIC"
    postcode.longitude.should == 144.96
    postcode.latitude.should == -37.8
  end

  it "should import Darwin postcodes '0800' data from csv correctly" do
    postcode = Postcode.find_by_number("0800")
    postcode.id.should == 2308
    postcode.suburbs.match (/^Darwin\\+\S$/)
    postcode.state.should == "NT"
    postcode.longitude.should == 130.84
    postcode.latitude.should == -12.46
  end
end
