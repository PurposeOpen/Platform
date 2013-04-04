require "spec_helper"

describe ActionPageObserver do

  describe "update" do
    it "should use 501(c)3 Recurly key if donation module is TaxDeductibleDonationModule" do
      page = create(:action_page)
      page.content_modules << build(:tax_deductible_donation_module)

      ENV["#{page.movement.slug}_501C3_RECURLY_KEY".upcase] = 'C3 key'
      Recurly.should_receive(:api_key=).with('C3 key')
      mock_plan = mock
      mock_plan.should_receive(:name).any_number_of_times.and_return(page.name)
      Recurly::Plan.should_receive(:find).any_number_of_times.and_return(mock_plan)

      ActionPageObserver.update(page)
    end

    it "should use 501(c)4 Recurly key if donation module is NonTaxDeductibleDonationModule" do
      page = create(:action_page)
      page.content_modules << build(:non_tax_deductible_donation_module)

      ENV["#{page.movement.slug}_501C4_RECURLY_KEY".upcase] = 'C4 key'
      Recurly.should_receive(:api_key=).with('C4 key')
      mock_plan = mock
      mock_plan.should_receive(:name).any_number_of_times.and_return(page.name)
      Recurly::Plan.should_receive(:find).any_number_of_times.and_return(mock_plan)

      ActionPageObserver.update(page)
    end

    it "should not call Recurly if Recurly.key is not set" do
      page = create(:action_page)
      page.content_modules << build(:non_tax_deductible_donation_module)
      Recurly::Plan.should_not_receive(:find)

      ENV["#{page.movement.slug}_501C4_RECURLY_KEY".upcase] = nil

      ActionPageObserver.update(page)
    end

    it "should not call Recurly if is not a donation page" do
      page = create(:action_page)
      page.content_modules << build(:petition_module)
      Recurly::Plan.should_not_receive(:find)
      ActionPageObserver.update(page)
    end

    it "should not create plan if already exists" do
       page = create(:action_page)
       page.content_modules << build(:non_tax_deductible_donation_module)
       monthly_plan = "#{page.id}--monthly"

       ENV["#{page.movement.slug}_501C4_RECURLY_KEY".upcase] = "some key"

       monthly_mock_plan = mock
       monthly_mock_plan.should_receive(:name).and_return(page.name)


       Recurly::Plan.should_receive(:find).with(monthly_plan).and_return(monthly_mock_plan)

       Recurly::Plan.should_not_receive(:create)

       ActionPageObserver.update(page)
     end

    it "should update plan name if already exists" do
      page = create(:action_page)
      page.content_modules << build(:non_tax_deductible_donation_module)
      page.name = 'New Donation Page'
      monthly_plan = "#{page.id}--monthly"

      ENV["#{page.movement.slug}_501C4_RECURLY_KEY".upcase] = "some key"

      monthly_mock_plan = mock
      monthly_mock_plan.should_receive(:name).and_return('Old Donation Page')

      Recurly::Plan.should_receive(:find).with(monthly_plan).and_return(monthly_mock_plan)

      monthly_mock_plan.should_receive(:name=).with('New Donation Page')
      monthly_mock_plan.should_receive(:save)

      ActionPageObserver.update(page)
    end

    it "should create onetime and monthly plans if it does not exists for Tax Deductible account" do
      action_page = create(:action_page)
      action_page.content_modules << build(:tax_deductible_donation_module)
      monthly_plan = "#{action_page.id}--monthly"

      ENV["#{action_page.movement.slug}_501C3_RECURLY_KEY".upcase] = "some key"
      Recurly::Plan.should_receive(:find).with(monthly_plan).and_raise(Recurly::Resource::NotFound.new 'Resource not found')

      plan = OpenStruct.new
      plan.response = OpenStruct.new
      plan.response.code = '201'

      monthly_params = {
          :plan_code => monthly_plan,
          :name => action_page.name,
          :unit_amount_in_cents => {'USD' => 100, 'EUR' => 100, 'CAD' => 100, 'AUD' => 100, 'GBP' => 100},
          :setup_fee_in_cents => {'USD' => 0, 'EUR' => 0, 'CAD' => 0, 'AUD' => 0, 'GBP' => 0},
          :plan_interval_length => 1,
          :plan_interval_unit => 'months',
          :total_billing_cycles => nil,
          :display_quantity => true,
          :success_url => "#{action_page.movement.url}/handle_payment_callback?account_code={{account_code}}&plan_code={{plan_code}}&classification=501(c)3",
          :cancel_url => "#{action_page.movement.url}/#{action_page.slug}"
      }

      Recurly::Plan.should_receive(:create).with(monthly_params).and_return(plan)

      ActionPageObserver.update(action_page)
    end

    it "should create onetime and monthly plans if it does not exists for Non Tax Deductible account" do
      action_page = create(:action_page)
      action_page.content_modules << build(:non_tax_deductible_donation_module)
      monthly_plan = "#{action_page.id}--monthly"

      ENV["#{action_page.movement.slug}_501C4_RECURLY_KEY".upcase] = "some key"
      Recurly::Plan.should_receive(:find).with(monthly_plan).and_raise(Recurly::Resource::NotFound.new 'Resource not found')

      plan = OpenStruct.new
      plan.response = OpenStruct.new
      plan.response.code = '201'

      monthly_params = {
          :plan_code => monthly_plan,
          :name => action_page.name,
          :unit_amount_in_cents => {'USD' => 100, 'EUR' => 100, 'CAD' => 100, 'AUD' => 100, 'GBP' => 100},
          :setup_fee_in_cents => {'USD' => 0, 'EUR' => 0, 'CAD' => 0, 'AUD' => 0, 'GBP' => 0},
          :plan_interval_length => 1,
          :plan_interval_unit => 'months',
          :total_billing_cycles => nil,
          :display_quantity => true,
          :success_url => "#{action_page.movement.url}/handle_payment_callback?account_code={{account_code}}&plan_code={{plan_code}}&classification=501(c)4",
          :cancel_url => "#{action_page.movement.url}/#{action_page.slug}"
      }

      Recurly::Plan.should_receive(:create).with(monthly_params).and_return(plan)

      ActionPageObserver.update(action_page)
    end

    it "should use first header content module's content as plan name on creation" do
      action_page = create(:action_page)
      donation_module = create(:non_tax_deductible_donation_module)
      action_page.content_module_links << create(:content_module_link, :page => action_page, :content_module => donation_module)
      header_module = create(:html_module, :content => 'Donation Campaign')
      action_page.content_module_links << create(:header_module_link, :page => action_page, :content_module => header_module)
      action_page.content_modules(true) # reload association to avoid cache issues
      ENV["#{action_page.movement.slug}_501C4_RECURLY_KEY".upcase] = "some key"
      monthly_plan = "#{action_page.id}--monthly"

      Recurly::Plan.should_receive(:find).with(monthly_plan).and_raise(Recurly::Resource::NotFound.new 'Resource not found')

      plan = OpenStruct.new
      plan.response = OpenStruct.new
      plan.response.code = '201'

      monthly_params = {
          :plan_code => monthly_plan,
          :name => 'Donation Campaign',
          :unit_amount_in_cents => {'USD' => 100, 'EUR' => 100, 'CAD' => 100, 'AUD' => 100, 'GBP' => 100},
          :setup_fee_in_cents => {'USD' => 0, 'EUR' => 0, 'CAD' => 0, 'AUD' => 0, 'GBP' => 0},
          :plan_interval_length => 1,
          :plan_interval_unit => 'months',
          :total_billing_cycles => nil,
          :display_quantity => true,
          :success_url => "#{action_page.movement.url}/handle_payment_callback?account_code={{account_code}}&plan_code={{plan_code}}&classification=501(c)4",
          :cancel_url => "#{action_page.movement.url}/#{action_page.slug}"
      }

      Recurly::Plan.should_receive(:create).with(monthly_params).and_return(plan)

      ActionPageObserver.update(action_page)
    end

    it "should raise error if plan cannot be created" do
      page = create(:action_page)
      page.content_modules << build(:non_tax_deductible_donation_module)
      monthly_plan = "#{page.id}--monthly"

      ENV["#{page.movement.slug}_501C4_RECURLY_KEY".upcase] = "some key"

      Recurly::Plan.should_receive(:find).with(monthly_plan).and_raise(Recurly::Resource::NotFound.new 'Resource not found')

      plan = OpenStruct.new
      plan.response = OpenStruct.new
      plan.response.code = '400'
      Recurly::Plan.should_receive(:create).and_return(plan)

      expect {ActionPageObserver.update(page)}.to raise_error

    end

  end
end