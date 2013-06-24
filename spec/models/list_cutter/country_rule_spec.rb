require "spec_helper"

describe ListCutter::CountryRule do
  before(:each) do
    @rule = ListCutter::CountryRule.new(:selected_by => 'name', :values => ["BRAZIL"])
  end

  describe 'validation' do
    it "should mandate selected_by" do
      rule = ListCutter::CountryRule.new(:selected_by => '')
      rule.should_not be_valid
      rule.errors.messages == {:selected_by => ["Please choose the criteria"]}
    end

    it "should mandate values" do
      rule = ListCutter::CountryRule.new(:selected_by => 'name', :values => [])
      rule.should_not be_valid
      rule.errors.messages == {:values => ["Please choose values"]}
    end
  end

  describe do
    before(:each) do
      @action_page = create(:action_page)
      @user1 = create(:user, :movement => @action_page.movement, :country_iso => "BR")
      @user2 = create(:user, :movement => @action_page.movement, :country_iso => "AR")
      @user3 = create(:user, :movement => @action_page.movement, :country_iso => "EE")
      @user4 = create(:user, :movement => @action_page.movement, :country_iso => "US")
    end

    it 'should return users based on commonwealth' do
      rule = ListCutter::CountryRule.new(:selected_by => 'commonwealth', :values => ['true'], :not => false, :movement => @action_page.movement)
      Country.should_receive(:iso_codes_with).with('commonwealth', ['true']).and_return(['EE', 'US'])
      rule.to_relation.all.should =~ [ @user3, @user4 ]
    end

    it 'should return users based on region' do
      rule = ListCutter::CountryRule.new(:selected_by => 'region_id', :values => ['2', '8'], :not => false, :movement => @action_page.movement)
      Country.should_receive(:iso_codes_with).with('region_id', ['2', '8']).and_return(['BR', 'AR'])
      rule.to_relation.all.should =~ [ @user1, @user2 ]
    end
  end

  describe "to_human_sql" do
    it "should return human readable form of conditions for name" do
      ListCutter::CountryRule.new(:selected_by => 'name', :values => ["ARGENTINA", "UNITED STATES"], :not => false).to_human_sql.should == "Country Name is any of these: ARGENTINA, UNITED STATES"
      ListCutter::CountryRule.new(:selected_by => 'name', :values => ["ARGENTINA", "UNITED STATES"], :not => true).to_human_sql.should == "Country Name is not any of these: ARGENTINA, UNITED STATES"
    end

    it "should return human readable form of conditions for region" do
      Country.stub(:region_names_for_ids).with(['1', '2']).and_return(["Africa - Eastern Africa", "Africa - Middle Africa"])
      ListCutter::CountryRule.new(:selected_by => 'region_id', :values => ['1', '2'], :not => false).to_human_sql.should == "Country Region is any of these: Africa - Eastern Africa, Africa - Middle Africa"
      ListCutter::CountryRule.new(:selected_by => 'region_id', :values => ['1', '2'], :not => true).to_human_sql.should == "Country Region is not any of these: Africa - Eastern Africa, Africa - Middle Africa"
    end

    it "should return human readable form of conditions for common wealth" do
      ListCutter::CountryRule.new(:selected_by => 'commonwealth', :values => ['true'], :not => false).to_human_sql.should == "Country Common Wealth is true"
      ListCutter::CountryRule.new(:selected_by => 'commonwealth', :values => ['true'], :not => true).to_human_sql.should == "Country Common Wealth is not true"
    end
  end

end
