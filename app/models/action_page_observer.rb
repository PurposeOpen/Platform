class ActionPageObserver

  def self.update(action_page)
    return true if not action_page.is_donation?
    account_type = action_page.is_tax_deductible_donation? ? '501C3' : '501C4'
    recurly_key = ENV["#{action_page.movement.slug}_#{account_type}_RECURLY_KEY".upcase]
    return true if recurly_key.nil?

    Recurly.api_key = recurly_key

    plan_name = action_page.name

    action_page.header_content_modules.each do |my_module|
      if (!my_module.content.empty?)
        plan_name = my_module.content
        break
      end
    end

    monthly_plan_id = "#{action_page.id}--monthly"
    begin
      monthly_plan = Recurly::Plan.find(monthly_plan_id)
      ensure_plan_name(monthly_plan, plan_name)
    rescue Recurly::Resource::NotFound
      create_plan(action_page, plan_name, monthly_plan_id, 'months',nil, account_type)
    end

    return true
  end

  def self.ensure_plan_name(plan, plan_name)
    if (plan.name != plan_name)
      plan.name = plan_name
      plan.save
    end
  end

  def self.create_plan(action_page, plan_name, plan_id, plan_interval_unit, billing_cycles, recurly_account_type)
    donation_classification = recurly_account_type == '501C3' ? TaxDeductibleDonationModule.classification : NonTaxDeductibleDonationModule.classification
    plan = Recurly::Plan.create(
        :plan_code => plan_id,
        :name => plan_name,
        :unit_amount_in_cents => {'USD' => 100, 'EUR' => 100, 'CAD' => 100, 'AUD' => 100, 'GBP' => 100},
        :setup_fee_in_cents => {'USD' => 0, 'EUR' => 0, 'CAD' => 0, 'AUD' => 0, 'GBP' => 0},
        :plan_interval_length => 1,
        :plan_interval_unit => plan_interval_unit,
        :total_billing_cycles => billing_cycles,
        :display_quantity => true,
        :success_url => "#{action_page.movement.url}/handle_payment_callback?account_code={{account_code}}&plan_code={{plan_code}}&classification=#{donation_classification}",
        :cancel_url => "#{action_page.movement.url}/#{action_page.slug}"
    )
    if (plan.response.code != '201')
      Rails.logger.error("An error happened on plan creating: #{plan.response.inspect}")
      raise RecurlyError.new("Error while trying to create a new plan")
    end
  end

end