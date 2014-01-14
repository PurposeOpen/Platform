module Admin::ListCutterHelper
  def rules_for_form
    [
        {label: "Country", class: ListCutter::CountryRule},
        {label: "Zone", class: ListCutter::ZoneRule},
        {label: "Domain", class: ListCutter::EmailDomainRule},
        {label: "Campaigns", class: ListCutter::CampaignRule},
        {label: "Action Page", class: ListCutter::ActionTakenRule},
        {label: "Email status", class: ListCutter::EmailActionRule},
        {label: "Join Date", class: ListCutter::JoinDateRule},
        {label: "Member Activity", class: ListCutter::MemberActivityRule},
        {label: "Source", class: ListCutter::MemberSourceRule},
        {label: "Originating Action", class: ListCutter::OriginatingActionRule},
        {label: "Member Email Activity", class: ListCutter::MemberEmailActivityRule},
        {label: "Donation Amount", class: ListCutter::DonationAmountRule},
        {label: "Recurring Donation Amount", class: ListCutter::RecurringDonationAmountRule},
        {label: "Donation Date", class: ListCutter::MostRecentDonationsRule},
        {label: "Donation Frequency", class: ListCutter::DonorRule},
        {label: "Donation Status", class: ListCutter::RecurringDonationsRule},
        {label: "User has no country", class: ListCutter::NoCountryRule}
    ]
  end

  def error_for(model, key)
    model.errors[key].inject("") do |acc, msg|
      acc << "<span class=\"error\">#{msg}</span>"
    end
  end

  def get_rule(list, rule_class)
    list.rules.select { |r| r.class == rule_class }.first || rule_class.new
  end

  def electorate_select_options
    Electorate.all.inject({}) do |acc, e|
      acc[e.name] = e.id
      acc
    end
  end

  def grouped_select_options_emails(movement_id, selected)
    store_key = "/grouped_select_options_email/#{movement_id}"
    store = Rails.cache.fetch(store_key)
    return create_opt_groups(store, selected) if !store.nil?

    store = Hash.new
    Campaign.joins(:movement).where("campaigns.movement_id = %d", movement_id).order("campaigns.updated_at desc").select("campaigns.id, campaigns.name").each {|campaign|
      campaign_blasts = Blast.joins(:push).where("pushes.campaign_id = #{campaign.id}")
      blasts_for_campaign = construct_group_options_hash(campaign_blasts, :emails, &nil)
      store[campaign.name] = blasts_for_campaign if !blasts_for_campaign.empty?
    }
    Rails.cache.write(store_key, store)
    create_opt_groups(store, selected)
  end

  def grouped_select_options_pages(movement_id, selected)
    store_key = "/grouped_select_options_pages/#{movement_id}"
    store = Rails.cache.fetch(store_key)
    Rails.logger.info("Got #{store}")
    return create_opt_groups(store, selected) if !store.nil?

    store = Hash.new
    Campaign.joins(:movement).where("campaigns.movement_id = %d", movement_id).order("campaigns.updated_at desc").select("campaigns.id, campaigns.name").each {|campaign|
      campaign_action_sequences = ActionSequence.joins(:campaign).where("action_sequences.campaign_id = %d", campaign.id)
      condition_for_inclusion = Proc.new{|action_page| (action_page.has_an_ask? && !action_page.is_unsubscribe? )}
      action_sequences_for_campaign = construct_group_options_hash(campaign_action_sequences, :action_pages, &condition_for_inclusion)
      store[campaign.name] = action_sequences_for_campaign if !action_sequences_for_campaign.empty?
    }
    Rails.cache.write(store_key, store)
    create_opt_groups(store, selected)
  end

  def select_options_action_pages(movement_id, selected)
    store_key = "/select_options_pages/#{movement_id}"
    store = Rails.cache.fetch(store_key)
    return options_for_select(store, selected) if !store.nil?

    store = ActionPage.page_options(movement_id, ListCutter::OriginatingActionRule::POSSIBLE_MODULE_TYPES)
    Rails.cache.write(store_key, store)
    response = options_for_select(store, selected)
    response.gsub(/\n/, '').html_safe
  end


  def filter_selected?(rule, rule_option)
    rule.class == rule_option[:class] ? "selected='selected'".html_safe : ""
  end

  def member_activity_select_options
    UserActivityEvent::Activity.constants.map do |activity_type|
      [activity_type, UserActivityEvent::Activity.const_get(activity_type)]
    end
  end

  private
  def construct_group_options_hash(values_for_opt_groups, value_for_options, &include_condition )
    hash = {}
    values_for_opt_groups.each { |value|
      options = []
      value.send(value_for_options).each { |option_val|
        options << [option_val.name, option_val.id] if (include_condition.nil? || include_condition.call(option_val))
      }
      next if options.size == 0
      map_from_hash = hash[value.name]
      if (map_from_hash)
        hash[value.name] = map_from_hash + options
      else
        hash[value.name] = options
      end
    }
    hash
  end

  def create_opt_groups(store, selected)
    new_select_options = ''
    store.keys.each { |key|
      new_select_options += "<optgroup label=\"#{key}\" parent-group=\"true\"></optgroup>"
      new_select_options += create_group_options(store[key], selected)
    }
    new_select_options.gsub(/\n/, '').html_safe
  end

  def create_group_options(grouped_options, selected_key)
    body = ''
    grouped_options.sort.each do |group|
      body << content_tag(:optgroup, options_for_select(group[1], selected_key), :label => group[0], id: SecureRandom.uuid)
    end
    body.html_safe
  end
end
